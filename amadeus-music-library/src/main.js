import {
  generatedAsTracks,
  officialAsTracks,
  searchTracks,
  formatDuration,
  uniqueMoods,
} from "./catalog.js";
import { createPlayer } from "./player.js";
import { createAudioBackend } from "./audio-backend.js";
import {
  loadLibraryState,
  saveLibraryState,
  toggleFavorite,
  createPlaylist,
  addToPlaylist,
  deletePlaylist,
  createLocalTrack,
  isAudioFile,
} from "./library.js";

const sessions = generatedAsTracks();
const official = officialAsTracks();
let localTracks = [];
let lib = loadLibraryState();
let view = lib.lastView || "sessions";
let query = "";
let mood = "all";
let selectedPlaylistId = null;

const backend = createAudioBackend();
const player = createPlayer({
  backend,
  onChange: renderPlayer,
});

player.setVolume(lib.volume ?? 0.82);
player.setQueue(sessions, lib.lastTrackId);

const $ = (id) => document.getElementById(id);

function allPlayable() {
  return [...sessions, ...localTracks];
}

function catalogForView() {
  if (view === "sessions") return sessions;
  if (view === "official") return official;
  if (view === "local") return localTracks;
  if (view === "favorites") {
    return allPlayable().filter((track) => lib.favorites.includes(track.id));
  }
  if (view === "playlist") {
    const playlist = lib.playlists.find((item) => item.id === selectedPlaylistId);
    if (!playlist) return [];
    return playlist.trackIds
      .map((id) => allPlayable().find((track) => track.id === id))
      .filter(Boolean);
  }
  return sessions;
}

function visibleTracks() {
  const moodFiltered = mood === "all" ? catalogForView() : catalogForView().filter((track) => track.mood === mood);
  return searchTracks(moodFiltered, query);
}

function persist() {
  lib.volume = player.getState().volume;
  lib.lastTrackId = player.getState().current?.id ?? lib.lastTrackId;
  lib.lastView = view;
  saveLibraryState(lib);
}

function setView(next, playlistId = null) {
  view = next;
  selectedPlaylistId = playlistId;
  persist();
  render();
}

function renderNav() {
  const playlists = lib.playlists
    .map(
      (playlist) => `
      <button class="nav-item ${view === "playlist" && selectedPlaylistId === playlist.id ? "active" : ""}" data-view="playlist" data-playlist="${playlist.id}">
        <span>${escapeHtml(playlist.name)}</span>
        <span class="count">${playlist.trackIds.length}</span>
      </button>`,
    )
    .join("");

  $("nav").innerHTML = `
    <p class="nav-label">Collections</p>
    ${navButton("sessions", "Worldline Sessions", sessions.length)}
    ${navButton("official", "Official Index", official.length)}
    ${navButton("local", "Local Imports", localTracks.length)}
    ${navButton("favorites", "Favorites", lib.favorites.length)}
    <p class="nav-label">Playlists</p>
    ${playlists || `<p class="nav-empty">No playlists yet.</p>`}
    <button id="new-playlist" class="ghost">New playlist</button>
    ${view === "playlist" && selectedPlaylistId ? `<button id="delete-playlist" class="ghost">Delete playlist</button>` : ""}
  `;

  $("nav").querySelectorAll("[data-view]").forEach((button) => {
    button.addEventListener("click", () => setView(button.dataset.view, button.dataset.playlist || null));
  });
  $("new-playlist").addEventListener("click", () => {
    const name = prompt("Playlist name", "Lab mix");
    if (!name) return;
    const result = createPlaylist(lib, name);
    lib = result.state;
    persist();
    setView("playlist", result.playlist.id);
  });
  $("delete-playlist")?.addEventListener("click", () => {
    if (!selectedPlaylistId) return;
    lib = deletePlaylist(lib, selectedPlaylistId);
    persist();
    setView("sessions");
  });
}

function navButton(id, label, count) {
  return `<button class="nav-item ${view === id ? "active" : ""}" data-view="${id}">
    <span>${label}</span><span class="count">${count}</span>
  </button>`;
}

function renderToolbar() {
  const tracks = catalogForView();
  const moods = ["all", ...uniqueMoods(tracks)];
  $("toolbar").innerHTML = `
    <div>
      <p class="kicker">${headerKicker()}</p>
      <h2>${headerTitle()}</h2>
    </div>
    <div class="tools">
      <input id="search" type="search" placeholder="Search title, mood, worldline…" value="${escapeAttr(query)}" />
      <select id="mood">
        ${moods.map((item) => `<option value="${item}" ${item === mood ? "selected" : ""}>${item}</option>`).join("")}
      </select>
      ${view === "local" ? `<label class="file-btn">Import audio<input id="file-input" type="file" accept="audio/*" multiple /></label>` : ""}
    </div>
  `;
  $("search").addEventListener("input", (event) => {
    query = event.target.value;
    renderList();
  });
  $("mood").addEventListener("change", (event) => {
    mood = event.target.value;
    renderList();
  });
  const fileInput = $("file-input");
  if (fileInput) fileInput.addEventListener("change", (event) => void importFiles(event.target.files));
}

function headerKicker() {
  if (view === "official") return "Metadata only · buy or stream the official releases";
  if (view === "local") return "Files stay in this browser session";
  if (view === "favorites") return "Pinned worldline sessions";
  if (view === "playlist") return lib.playlists.find((item) => item.id === selectedPlaylistId)?.name || "Playlist";
  return "Original generative sessions · Web Audio";
}

function headerTitle() {
  if (view === "official") return "Official Amadeus index";
  if (view === "local") return "Local imports";
  if (view === "favorites") return "Favorites";
  if (view === "playlist") return "Playlist";
  return "Worldline Sessions";
}

function renderList() {
  const tracks = visibleTracks();
  const currentId = player.getState().current?.id;
  if (!tracks.length) {
    $("list").innerHTML = `<div class="empty">${emptyMessage()}</div>`;
    return;
  }
  $("list").innerHTML = tracks
    .map((track, index) => {
      const fav = lib.favorites.includes(track.id);
      const officialLinks = track.links
        ? Object.entries(track.links)
            .map(([key, url]) => `<a href="${url}" target="_blank" rel="noreferrer">${key}</a>`)
            .join(" · ")
        : "";
      return `
      <article class="row ${track.id === currentId ? "current" : ""} ${track.playable === false ? "locked" : ""}" data-id="${track.id}">
        <button class="index" data-play="${track.id}">${track.id === currentId && player.getState().playing ? "▶" : String(index + 1).padStart(2, "0")}</button>
        <div class="meta">
          <strong>${escapeHtml(track.title)}</strong>
          <span>${escapeHtml(track.artist)} · ${escapeHtml(track.album || "")}</span>
          <em>${escapeHtml(track.blurb || "")}</em>
          ${officialLinks ? `<span class="links">${officialLinks}</span>` : ""}
        </div>
        <span class="chip">${escapeHtml(track.mood)}</span>
        <span class="chip dim">${escapeHtml(track.worldline || "")}</span>
        <span class="time">${track.durationSec ? formatDuration(track.durationSec) : "—"}</span>
        <button class="icon ${fav ? "on" : ""}" data-fav="${track.id}" title="Favorite">★</button>
        ${
          lib.playlists.length && track.playable !== false
            ? `<button class="icon" data-add="${track.id}" title="Add to playlist">＋</button>`
            : ""
        }
        ${
          view === "playlist"
            ? `<button class="icon" data-del-pl="${selectedPlaylistId}" data-del-track="${track.id}" title="Remove">✕</button>`
            : ""
        }
      </article>`;
    })
    .join("");

  $("list").querySelectorAll("[data-play]").forEach((button) => {
    button.addEventListener("click", () => playId(button.dataset.play));
  });
  $("list").querySelectorAll("article").forEach((row) => {
    row.addEventListener("dblclick", () => playId(row.dataset.id));
  });
  $("list").querySelectorAll("[data-fav]").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.stopPropagation();
      lib = toggleFavorite(lib, button.dataset.fav);
      persist();
      render();
    });
  });
  $("list").querySelectorAll("[data-add]").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.stopPropagation();
      const names = lib.playlists.map((playlist, index) => `${index + 1}. ${playlist.name}`).join("\n");
      const choice = prompt(`Add to playlist:\n${names}\n\nEnter number`);
      const playlist = lib.playlists[Number(choice) - 1];
      if (!playlist) return;
      lib = addToPlaylist(lib, playlist.id, button.dataset.add);
      persist();
      renderNav();
    });
  });
  $("list").querySelectorAll("[data-del-track]").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.stopPropagation();
      const playlist = lib.playlists.find((item) => item.id === button.dataset.delPl);
      if (!playlist) return;
      playlist.trackIds = playlist.trackIds.filter((id) => id !== button.dataset.delTrack);
      persist();
      render();
    });
  });
}

function emptyMessage() {
  if (view === "local") return "Import mp3 / wav / ogg / flac files to build a private shelf.";
  if (view === "favorites") return "Star a session to pin it here.";
  if (view === "playlist") return "Add playable tracks to this playlist.";
  return "No matches on this worldline.";
}

function playId(id) {
  const track = [...sessions, ...official, ...localTracks].find((item) => item.id === id);
  if (!track) return;
  if (track.playable === false) {
    renderPlayer({ ...player.getState(), error: "Official index is metadata only — use the VGMdb links." });
    return;
  }
  const queue = view === "official" ? sessions : visibleTracks().filter((item) => item.playable !== false);
  void player.play(track, queue.length ? queue : allPlayable());
  persist();
}

function renderPlayer(state = player.getState()) {
  const track = state.current;
  $("now-title").textContent = track ? track.title : "No signal";
  $("now-sub").textContent = track
    ? `${track.artist} · ${track.worldline || track.album || ""}`
    : "Select a Worldline Session";
  $("play-btn").textContent = state.playing ? "❚❚" : "▶";
  $("time-cur").textContent = formatDuration(state.currentTime);
  $("time-dur").textContent = formatDuration(state.duration || track?.durationSec || 0);
  const duration = state.duration || track?.durationSec || 1;
  $("seek").value = String((state.currentTime / duration) * 1000);
  $("volume").value = String(Math.round((state.muted ? 0 : state.volume) * 100));
  $("shuffle-btn").classList.toggle("on", state.shuffle);
  $("repeat-btn").classList.toggle("on", state.repeat !== "off");
  $("repeat-btn").textContent = state.repeat === "one" ? "🔂" : "🔁";
  $("status-line").textContent = state.error
    ? state.error
    : state.playing
      ? `PLAYING · ${track?.worldline || "local"}`
      : "STANDBY";
  $("meter").textContent = track?.worldline && track.worldline.includes(".") ? track.worldline : "1.048596";
  if ($("list").querySelector(".row")) renderList();
}

function render() {
  renderNav();
  renderToolbar();
  renderList();
  renderPlayer();
}

async function importFiles(fileList) {
  const files = [...fileList].filter(isAudioFile);
  for (const file of files) {
    const objectUrl = URL.createObjectURL(file);
    const id = `local-${file.name}-${file.size}-${file.lastModified}`;
    if (localTracks.some((track) => track.id === id)) continue;
    localTracks.push(createLocalTrack(file, { id, objectUrl }));
  }
  render();
}

function drawVisualizer() {
  const canvas = $("viz");
  const ctx2d = canvas.getContext("2d");
  const resize = () => {
    canvas.width = canvas.clientWidth * devicePixelRatio;
    canvas.height = canvas.clientHeight * devicePixelRatio;
  };
  resize();
  window.addEventListener("resize", resize);

  const frame = () => {
    const analyser = backend.getAnalyser();
    ctx2d.clearRect(0, 0, canvas.width, canvas.height);
    ctx2d.fillStyle = "rgba(97, 238, 182, 0.85)";
    if (!analyser) {
      const mid = canvas.height / 2;
      ctx2d.fillRect(0, mid, canvas.width, 1);
      requestAnimationFrame(frame);
      return;
    }
    const bins = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteFrequencyData(bins);
    const barWidth = canvas.width / 72;
    for (let i = 0; i < 72; i += 1) {
      const value = bins[Math.floor((i / 72) * bins.length)] / 255;
      const h = value * canvas.height;
      ctx2d.globalAlpha = 0.35 + value * 0.65;
      ctx2d.fillRect(i * barWidth, canvas.height - h, barWidth - 2, h);
    }
    requestAnimationFrame(frame);
  };
  frame();
}

function bindTransport() {
  $("play-btn").addEventListener("click", () => {
    const state = player.getState();
    if (!state.current) {
      void player.play(sessions[0], sessions);
      return;
    }
    void player.toggle();
  });
  $("prev-btn").addEventListener("click", () => void player.previous());
  $("next-btn").addEventListener("click", () => void player.next());
  $("shuffle-btn").addEventListener("click", () => player.toggleShuffle());
  $("repeat-btn").addEventListener("click", () => player.cycleRepeat());
  $("seek").addEventListener("input", (event) => {
    const state = player.getState();
    const duration = state.duration || state.current?.durationSec || 0;
    player.seek((Number(event.target.value) / 1000) * duration);
  });
  $("volume").addEventListener("input", (event) => {
    player.setVolume(Number(event.target.value) / 100);
    persist();
  });
  document.addEventListener("keydown", (event) => {
    if (event.target.matches("input, textarea, select")) return;
    if (event.code === "Space") {
      event.preventDefault();
      void player.toggle();
    }
    if (event.code === "ArrowRight") void player.next();
    if (event.code === "ArrowLeft") void player.previous();
  });

  const drop = $("app");
  drop.addEventListener("dragover", (event) => {
    event.preventDefault();
    drop.classList.add("drop");
  });
  drop.addEventListener("dragleave", () => drop.classList.remove("drop"));
  drop.addEventListener("drop", (event) => {
    event.preventDefault();
    drop.classList.remove("drop");
    void importFiles(event.dataTransfer.files);
    setView("local");
  });
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function escapeAttr(value) {
  return escapeHtml(value);
}

render();
bindTransport();
drawVisualizer();
