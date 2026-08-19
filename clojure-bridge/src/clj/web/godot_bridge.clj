(ns web.godot-bridge
  "Thin HTTP JSON API so Godot can drive the live mtgred/netrunner engine.
  Routes are mounted without CSRF. Games live in memory on this JVM."
  (:require
   [clojure.string :as str]
   [game.core.board :as board]
   [game.core.card :as card]
   [game.core.diffs :as diffs]
   [game.core.process-actions :as pa]
   [game.core.set-up :as set-up]
   [game.core.turns :as turns]
   [game.utils :as utils]
   [jinteki.cards :as cards]
   [web.utils :refer [response]]))

(defonce games (atom {}))

(def beginner-corp-id "30077")
(def beginner-runner-id "30076")

(def beginner-corp-cards
  {"30067" 3 "30069" 2 "30070" 2 "30037" 2 "30071" 2 "30045" 2 "30064" 2
   "30075" 3 "30040" 2 "30042" 1 "30039" 2 "30072" 3 "30046" 2 "30074" 2
   "30047" 2 "30073" 2})

(def beginner-runner-cards
  {"30020" 2 "30028" 3 "30029" 2 "30030" 3 "30012" 2 "30021" 2 "30013" 1
   "30014" 1 "30018" 1 "30033" 2 "30027" 2 "30034" 1 "30015" 2 "30006" 2
   "30032" 2 "30026" 2})

(defn- jsonish [x]
  (cond
    (nil? x) nil
    (or (string? x) (number? x) (boolean? x)) x
    (keyword? x) (name x)
    (symbol? x) (name x)
    (instance? java.util.UUID x) (str x)
    (instance? java.time.Instant x) (str x)
    (map? x) (into {} (keep (fn [[k v]]
                              (let [jv (jsonish v)]
                                (when (some? jv)
                                  [(if (keyword? k) (name k) (str k)) jv])))
                            x))
    (or (sequential? x) (set? x)) (mapv jsonish x)
    :else nil))

(defn- card-by-code [code]
  (let [want (str code)]
    (some #(when (= want (str (:code %))) %) (utils/server-cards))))

(defn- deck-from-codes [identity-code qty-map]
  (let [ident (card-by-code identity-code)
        entries (vec (for [[code qty] qty-map
                           :let [c (card-by-code code)]
                           :when c]
                       {:qty qty :card c}))]
    (when-not ident
      (throw (ex-info (str "Missing identity " identity-code) {:code identity-code})))
    (when (empty? entries)
      (throw (ex-info "Deck resolved to zero cards" {:identity identity-code})))
    {:identity ident
     :cards entries}))

(defn- slim-card [c]
  (when (and c (or (:cid c) (:title c) (:code c)))
    (cond-> {:cid (:cid c)
             :code (:code c)
             :title (or (:title c) (:printed-title c))
             :type (:type c)
             :side (:side c)
             :cost (:cost c)
             :zone (mapv #(if (keyword? %) (name %) (str %)) (or (:zone c) []))}
      (:subtype c) (assoc :subtype (:subtype c))
      (seq (:subtypes c)) (assoc :subtypes (:subtypes c))
      (:advance-counter c) (assoc :advancement (:advance-counter c))
      (or (:current-advancement-requirement c) (:advancementcost c))
      (assoc :advancement_requirement (or (:current-advancement-requirement c)
                                          (:advancementcost c)))
      (:agendapoints c) (assoc :agenda_points (:agendapoints c))
      (some? (:rezzed c)) (assoc :rezzed (boolean (:rezzed c)))
      (or (:current-strength c) (:strength c))
      (assoc :strength (or (:current-strength c) (:strength c)))
      (:playable c) (assoc :playable true)
      (:seen c) (assoc :seen true))))

(defn- slim-server [server]
  {:ices (mapv slim-card (:ices server))
   :content (mapv slim-card (:content server))})

(defn- slim-servers [state]
  (let [servers (get-in @state [:corp :servers])]
    {:hq (slim-server (:hq servers))
     :rd (slim-server (:rd servers))
     :archives (slim-server (:archives servers))
     :remotes (vec (for [[kw server] servers
                         :when (and kw (str/starts-with? (name kw) "remote"))]
                     {:id (name kw)
                      :name (str "Server " (str/replace (name kw) #"remote" ""))
                      :ices (:ices (slim-server server))
                      :content (:content (slim-server server))}))}))

(defn- slim-log [state]
  (->> (:log @state)
       (map (fn [entry]
              (cond
                (string? entry) entry
                (map? entry)
                (let [msg (or (:public entry) (:corp entry) (:runner entry) entry)]
                  (cond
                    (string? msg) msg
                    (map? msg) (or (:text msg) "")
                    :else (str msg)))
                :else "")))
       (remove str/blank?)
       (take-last 40)
       vec))

(defn- prompt-of [state side]
  (let [p (or (get-in @state [side :prompt-state])
              (first (get-in @state [side :prompt])))]
    (when (and p (not= :waiting (:prompt-type p)))
      (assoc p :_side side))))

(defn- acting-prompt [state]
  (or (prompt-of state :corp) (prompt-of state :runner)))

(defn- choice-label [choice]
  (let [v (:value choice)]
    (cond
      (string? v) v
      (map? v) (or (:title v) (:printed-title v) (str (:cid v)))
      (keyword? v) (name v)
      :else (str v))))

(defn- prompt-actions [state]
  (when-let [p (acting-prompt state)]
    (let [side (:_side p)
          side-s (name side)
          choices (:choices p)]
      (cond
        (sequential? choices)
        (mapv (fn [ch]
                {:command "choice"
                 :side side-s
                 :label (choice-label ch)
                 :args {:choice {:uuid (str (:uuid ch))}}})
              choices)
        (= :select (:prompt-type p))
        (let [cids (or (seq (:selectable p))
                       (map :cid (get-in @state [side :hand])))]
          (mapv (fn [cid]
                  (let [c (some #(when (= cid (:cid %)) %) (board/get-all-cards state))]
                    {:command "select"
                     :side side-s
                     :label (str "Select " (or (:title c) cid))
                     :args {:card {:cid cid}}}))
                cids))
        (or (= :credit choices) (:number choices) (:counter choices))
        (let [mx (or (:max (:number choices)) 5)]
          (mapv (fn [n]
                  {:command "choice"
                   :side side-s
                   :label (str n)
                   :args {:choice n}})
                (range 0 (inc mx))))
        :else
        [{:command "choice"
          :side side-s
          :label (str (or (:msg p) "Continue"))
          :args {:choice 0}}]))))

(defn- playable-hand [state side]
  (keep (fn [c]
          (try
            (let [marked (diffs/playable? c state side)]
              (when (:playable marked) marked))
            (catch Exception _ c)))
        (get-in @state [side :hand])))

(defn- installed-cards [state]
  (concat (board/corp-servers-cards state)
          (board/runner-rig-cards state)))

(defn- can-score? [c]
  (and (= "Agenda" (:type c))
       (pos? (or (:advance-counter c) 0))
       (>= (or (:advance-counter c) 0)
           (or (:current-advancement-requirement c)
               (:advancementcost c)
               99))))

(defn- server-names [state]
  (or (seq (board/server-list state))
      ["HQ" "R&D" "Archives" "New remote"]))

(defn- ability-actions [state side card]
  (let [abs (or (:abilities card) [])]
    (keep-indexed
     (fn [idx ab]
       (when (or (:playable ab) (string? (:label ab)) (string? (:msg ab)))
         {:command "ability"
          :side (name side)
          :label (str (or (:title card) "?") ": " (or (:label ab) (:msg ab) (str "Ability " idx)))
          :args {:card {:cid (:cid card)} :ability idx}}))
     abs)))

(defn- legal-actions [state]
  (or (not-empty (prompt-actions state))
      (let [winner (:winner @state)
            active (or (:active-player @state) :corp)
            clicks (or (get-in @state [active :click]) 0)
            running? (boolean (:run @state))
            phase12? (or (get-in @state [:corp-phase-12 :active])
                         (get-in @state [:runner-phase-12 :active]))
            end-turn? (boolean (:end-turn @state))]
        (cond
          winner []
          end-turn?
          (let [nxt (if (= active :corp) :runner :corp)
                nxt (if (zero? (:turn @state)) :corp nxt)]
            [{:command "start-turn"
              :side (name nxt)
              :label (str "Start " (if (= nxt :corp) "Corp" "Runner") " turn")
              :args {}}])
          phase12?
          [{:command "end-phase-12"
            :side (name active)
            :label "Finish start-of-turn"
            :args {}}]
          :else
          (let [side active
                side-s (name side)
                hand-plays (for [c (playable-hand state side)]
                             {:command "play"
                              :side side-s
                              :label (str "Play " (:title c))
                              :args {:card {:cid (:cid c)}}})
                runs (when (and (= side :runner) (pos? clicks) (not running?))
                       (for [server (server-names state)]
                         {:command "run"
                          :side "runner"
                          :label (str "Run " server)
                          :args {:server server}}))
                rez (when (= side :corp)
                      (for [c (board/corp-servers-cards state)
                            :when (and (not (:rezzed c)) (:cid c))]
                        {:command "rez"
                         :side "corp"
                         :label (str "Rez " (or (:title c) "card"))
                         :args {:card {:cid (:cid c)}}}))
                advance (when (and (= side :corp) (pos? clicks))
                          (for [c (board/corp-servers-cards state)
                                :when (or (card/agenda? c)
                                          (card/asset? c)
                                          (:advanceable c)
                                          (pos? (or (:advance-counter c) 0)))]
                            {:command "advance"
                             :side "corp"
                             :label (str "Advance " (or (:title c) "card"))
                             :args {:card {:cid (:cid c)}}}))
                score (when (= side :corp)
                        (for [c (board/corp-servers-cards state)
                              :when (can-score? c)]
                          {:command "score"
                           :side "corp"
                           :label (str "Score " (:title c))
                           :args {:card {:cid (:cid c)}}}))
                abs (mapcat #(ability-actions state side %)
                            (filter #(= (if (= side :corp) "Corp" "Runner") (:side %))
                                    (installed-cards state)))
                run-cmds (when running?
                           (cond-> [{:command "continue"
                                     :side side-s
                                     :label "Continue run"
                                     :args {}}]
                             (= side :runner)
                             (conj {:command "jack-out"
                                    :side "runner"
                                    :label "Jack out"
                                    :args {}})))
                basics (cond-> []
                         (and (pos? clicks) (not running?))
                         (conj {:command "credit" :side side-s :label "Click for 1 credit" :args {}}
                               {:command "draw" :side side-s :label "Click to draw" :args {}})
                         (and (= side :runner) (pos? clicks)
                              (pos? (or (get-in @state [:runner :tag :total]) 0)))
                         (conj {:command "remove-tag" :side "runner" :label "Remove a tag" :args {}})
                         (and (not running?) (zero? clicks))
                         (conj {:command "end-turn" :side side-s :label "End turn" :args {}}))]
            (vec (concat basics hand-plays runs rez advance score abs run-cmds)))))))

(defn- player-view [state side]
  (let [p (get-in @state [side])
        mem (:memory p)
        tag (:tag p)]
    {:identity (slim-card (:identity p))
     :credits (or (:credit p) 0)
     :clicks (or (:click p) 0)
     :hand_size (or (:total (:hand-size p)) 5)
     :hand (mapv slim-card (:hand p))
     :hand_count (count (:hand p))
     :deck_count (count (:deck p))
     :discard (mapv slim-card (:discard p))
     :scored (mapv slim-card (:scored p))
     :agenda_points (or (:agenda-point p) 0)
     :agenda_point_req (or (:agenda-point-req p) 7)
     :rig (when (= side :runner)
            {:program (mapv slim-card (get-in p [:rig :program]))
             :hardware (mapv slim-card (get-in p [:rig :hardware]))
             :resource (mapv slim-card (get-in p [:rig :resource]))})
     :tags (or (:total tag) 0)
     :memory_used (or (:used mem) 0)
     :memory_base (or (:base mem) 4)
     :bad_publicity (+ (or (get-in p [:bad-publicity :base]) 0)
                       (or (get-in p [:bad-publicity :additional]) 0))}))

(defn- slim-run [state]
  (when-let [run (:run @state)]
    {:server (let [s (:server run)]
               (cond
                 (sequential? s) (str/join " " (map #(if (keyword? %) (name %) (str %)) s))
                 (keyword? s) (name s)
                 :else (str s)))
     :position (:position run)}))

(defn- slim-prompt [state]
  (when-let [p (acting-prompt state)]
    {:side (name (:_side p))
     :msg (:msg p)
     :type (some-> (:prompt-type p) name)}))

(defn game-view [id state]
  (jsonish
   {:ok true
    :id id
    :engine "mtgred/netrunner"
    :turn (or (:turn @state) 0)
    :active (name (or (:active-player @state) :corp))
    :end_turn (boolean (:end-turn @state))
    :winner (some-> (:winner @state) name)
    :reason (:reason @state)
    :corp (player-view state :corp)
    :runner (player-view state :runner)
    :servers (slim-servers state)
    :run (slim-run state)
    :prompt (slim-prompt state)
    :log (slim-log state)
    :actions (legal-actions state)}))

(defn- game-id [req]
  (or (get-in req [:params :id])
      (get-in req [:params "id"])
      (get-in req [:body :id])
      (get-in req [:body "id"])))

(defn- lookup [id]
  (when id
    (get @games (str id))))

(defn- begin-game! [agenda-goal]
  (let [corp-deck (deck-from-codes beginner-corp-id beginner-corp-cards)
        runner-deck (deck-from-codes beginner-runner-id beginner-runner-cards)
        gid (str (java.util.UUID/randomUUID))
        state (set-up/init-game
               {:gameid gid
                :format :system-gateway
                :api-access true
                :players [{:side "Corp"
                           :user {:username "Corp"}
                           :deck corp-deck}
                          {:side "Runner"
                           :user {:username "Runner"}
                           :deck runner-deck}]})]
    (when-not (= :keep (get-in @state [:corp :keep]))
      (set-up/keep-hand state :corp nil))
    (when-not (= :keep (get-in @state [:runner :keep]))
      (set-up/keep-hand state :runner nil))
    (when (or (:end-turn @state) (zero? (or (:turn @state) 0)))
      (turns/start-turn state :corp nil))
    (swap! state assoc-in [:corp :agenda-point-req] agenda-goal)
    (swap! state assoc-in [:runner :agenda-point-req] agenda-goal)
    (swap! games assoc gid state)
    (game-view gid state)))

(defn status-handler [_req]
  (response 200
            {:ok true
             :engine "mtgred/netrunner"
             :cards (count @cards/all-cards)
             :games (count @games)
             :bridge "godot"}))

(defn new-handler [req]
  (try
    (let [body (or (:body req) {})
          goal (or (:agenda_goal body) (:agenda-goal body) 6)]
      (response 200 (begin-game! (int goal))))
    (catch Exception e
      (response 500 {:ok false :error (.getMessage e)}))))

(defn state-handler [req]
  (if-let [state (lookup (game-id req))]
    (response 200 (game-view (str (game-id req)) state))
    (response 404 {:ok false :error "unknown game"})))

(defn- keywordize-side [side]
  (cond
    (keyword? side) side
    (#{"corp" "Corp" "CORP"} (str side)) :corp
    (#{"runner" "Runner" "RUNNER"} (str side)) :runner
    :else :corp))

(defn action-handler [req]
  (let [body (or (:body req) {})
        id (or (:id body) (game-id req))
        command (or (:command body) (:op body))
        side (keywordize-side (or (:side body) (:active-player body)))
        args (or (:args body) {})]
    (if-let [state (lookup id)]
      (try
        (when (str/blank? (str command))
          (throw (ex-info "missing command" {})))
        (pa/process-action (str command) state side args)
        (response 200 (game-view (str id) state))
        (catch Exception e
          (response 200 (assoc (game-view (str id) state)
                               :ok true
                               :error (.getMessage e)))))
      (response 404 {:ok false :error "unknown game"}))))
