class_name NRUtil
extends RefCounted
## Nested-dict helpers, identifiers, and string utilities matching game.utils / jinteki.utils.

static var _cid_seq: int = 0
static var _uuid_seq: int = 0

static func make_cid() -> String:
	_cid_seq += 1
	return "cid-%s-%d" % [Time.get_ticks_usec(), _cid_seq]


static func make_uuid() -> String:
	_uuid_seq += 1
	return "uuid-%s-%d" % [Time.get_ticks_usec(), _uuid_seq]


static func make_timestamp() -> int:
	return Time.get_ticks_msec()


static func to_side(value: Variant) -> String:
	if value == null:
		return ""
	var s := str(value).to_lower()
	if s.begins_with(":"):
		s = s.substr(1)
	if s == "corp":
		return "corp"
	if s == "runner":
		return "runner"
	return s


static func side_str(side: Variant) -> String:
	var s := to_side(side)
	if s == "corp":
		return "Corp"
	if s == "runner":
		return "Runner"
	return str(side)


static func other_side(side: Variant) -> String:
	return "runner" if to_side(side) == "corp" else "corp"


static func same_side(a: Variant, b: Variant) -> bool:
	return side_str(a) == side_str(b)


static func to_kw(value: Variant) -> String:
	if value == null:
		return ""
	if value is String:
		var s: String = value
		if s == "[Credits]":
			return "credit"
		if s.begins_with(":"):
			s = s.substr(1)
		return s.to_lower()
	if value is StringName:
		return str(value).to_lower()
	return str(value).to_lower()


static func kw_eq(a: Variant, b: Variant) -> bool:
	return to_kw(a) == to_kw(b)


static func same_card(card1: Variant, card2: Variant, key: String = "cid") -> bool:
	if not (card1 is Dictionary) or not (card2 is Dictionary):
		return false
	var id1 = card1.get(key)
	var id2 = card2.get(key)
	return id1 != null and id2 != null and id1 == id2


static func get_in(data: Variant, path: Array, default_value: Variant = null) -> Variant:
	var cur = data
	for key in path:
		if cur == null:
			return default_value
		if cur is Dictionary:
			if not cur.has(key):
				var alt := _alt_key(key)
				if alt != key and cur.has(alt):
					cur = cur[alt]
				else:
					return default_value
			else:
				cur = cur[key]
		elif cur is Array:
			var idx := int(key)
			if idx < 0 or idx >= cur.size():
				return default_value
			cur = cur[idx]
		else:
			return default_value
	return cur


static func _alt_key(key: Variant) -> Variant:
	if key is String and (key as String).begins_with(":"):
		return (key as String).substr(1)
	return key


static func assoc_in(data: Dictionary, path: Array, value: Variant) -> Dictionary:
	if path.is_empty():
		return data
	var d := data
	for i in range(path.size() - 1):
		var key = path[i]
		if not d.has(key) or not (d[key] is Dictionary):
			d[key] = {}
		d = d[key]
	d[path[path.size() - 1]] = value
	return data


static func update_in(data: Dictionary, path: Array, updater: Callable, default_value: Variant = 0) -> Dictionary:
	var cur = get_in(data, path, default_value)
	return assoc_in(data, path, updater.call(cur))


static func dissoc_in(data: Dictionary, path: Array) -> Dictionary:
	if path.is_empty():
		return data
	if path.size() == 1:
		data.erase(path[0])
		return data
	var parent_path := path.duplicate()
	parent_path.resize(path.size() - 1)
	var parent = get_in(data, parent_path)
	if parent is Dictionary:
		parent.erase(path[path.size() - 1])
	return data


static func inc_n(n: int) -> Callable:
	return func(v): return (0 if v == null else int(v)) + n


static func sub_to_zero(n: int) -> Callable:
	return func(v): return maxi(0, (0 if v == null else int(v)) - n)


static func remove_once(arr: Array, pred: Callable) -> Array:
	var out: Array = []
	var removed := false
	for item in arr:
		if not removed and pred.call(item):
			removed = true
			continue
		out.append(item)
	return out


static func find_first(arr: Array, pred: Callable) -> Variant:
	for item in arr:
		if pred.call(item):
			return item
	return null


static func in_coll(coll: Variant, elm: Variant) -> bool:
	if coll is Array:
		return elm in coll
	if coll is Dictionary:
		return coll.has(elm)
	return false


static func flatten(value: Variant) -> Array:
	var out: Array = []
	_flatten_into(value, out)
	return out


static func _flatten_into(value: Variant, out: Array) -> void:
	if value is Array:
		for v in value:
			_flatten_into(v, out)
	elif value != null:
		out.append(value)


static func filter_some(arr: Array) -> Array:
	var out: Array = []
	for v in arr:
		if v != null:
			out.append(v)
	return out


static func distinct_by(arr: Array, key_fn: Callable) -> Array:
	var seen := {}
	var out: Array = []
	for item in arr:
		var k = key_fn.call(item)
		if seen.has(k):
			continue
		seen[k] = true
		out.append(item)
	return out


static func shuffle_array(arr: Array) -> Array:
	var copy := arr.duplicate()
	copy.shuffle()
	return copy


static func take_n(arr: Array, n: int) -> Array:
	if n <= 0:
		return []
	return arr.slice(0, mini(n, arr.size()))


static func drop_n(arr: Array, n: int) -> Array:
	if n <= 0:
		return arr.duplicate()
	if n >= arr.size():
		return []
	return arr.slice(n)


static func quantify(n: int, word: String, suffix: String = "s") -> String:
	if n == 1 or n == -1:
		return "%d %s" % [n, word]
	return "%d %s%s" % [n, word, suffix]


static func pluralize(word: String, n: int, suffix: String = "s") -> String:
	if n == 1 or n == -1:
		return word
	return word + suffix


static func enumerate_str(strings: Array, sep: String = "and") -> String:
	var parts: Array = []
	for s in strings:
		if s != null and str(s) != "":
			parts.append(str(s))
	if parts.size() <= 2:
		return _join_two(parts, sep)
	var head := ", ".join(parts.slice(0, parts.size() - 1))
	return "%s, %s %s" % [head, sep, parts[parts.size() - 1]]


static func _join_two(parts: Array, sep: String) -> String:
	if parts.is_empty():
		return ""
	if parts.size() == 1:
		return str(parts[0])
	return "%s %s %s" % [parts[0], sep, parts[1]]


static func enumerate_cards(cards: Array, sorted: bool = false) -> String:
	var titles: Array = []
	for c in cards:
		if c is Dictionary:
			titles.append(str(c.get("title", c.get("printed-title", "a card"))))
	if sorted:
		titles.sort()
	return enumerate_str(titles)


static func is_fn(v: Variant) -> bool:
	return v is Callable


static func call_5(fn: Variant, state: Variant, side: Variant, eid: Variant, card: Variant, targets: Variant) -> Variant:
	if fn is Callable:
		return fn.call(state, side, eid, card, targets)
	return fn


static func call_maybe(fn: Variant, args: Array) -> Variant:
	if fn is Callable:
		return fn.callv(args)
	return fn


static func as_array(value: Variant) -> Array:
	if value == null:
		return []
	if value is Array:
		return value
	return [value]


static func zone_as_array(zone: Variant) -> Array:
	if zone == null:
		return []
	if zone is Array:
		var out: Array = []
		for z in zone:
			out.append(to_kw(z))
		return out
	return [to_kw(zone)]


static func first_of(arr: Variant) -> Variant:
	if arr is Array and not arr.is_empty():
		return arr[0]
	return null


static func last_of(arr: Variant) -> Variant:
	if arr is Array and not arr.is_empty():
		return arr[arr.size() - 1]
	return null


static func deepcopy(value: Variant) -> Variant:
	if value is Dictionary:
		var d: Dictionary = {}
		for k in value:
			d[k] = deepcopy(value[k])
		return d
	if value is Array:
		var a: Array = []
		for v in value:
			a.append(deepcopy(v))
		return a
	return value


static func select_keys(d: Dictionary, keys: Array) -> Dictionary:
	var out := {}
	for k in keys:
		if d.has(k):
			out[k] = d[k]
	return out


static func dissoc(d: Dictionary, keys: Array) -> Dictionary:
	var out := d.duplicate(true)
	for k in keys:
		out.erase(k)
	return out


static func merge(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := a.duplicate(true)
	for k in b:
		out[k] = b[k]
	return out


static func is_number(v: Variant) -> bool:
	return v is int or v is float


static func as_int(v: Variant, default_value: int = 0) -> int:
	if v == null:
		return default_value
	return int(v)


static func is_tagged(state: NRState) -> bool:
	return bool(state.get_in(["runner", "tag", "is-tagged"], false)) or as_int(state.get_in(["runner", "tag", "total"], 0)) > 0


static func count_bad_pub(state: NRState) -> int:
	var bp = state.get_in(["corp", "bad-publicity"], {})
	if bp is Dictionary:
		return as_int(bp.get("base", 0)) + as_int(bp.get("additional", 0))
	return as_int(bp, 0)


static func make_label(ability: Dictionary) -> String:
	if ability.has("label") and ability["label"] is String:
		return ability["label"]
	if ability.has("msg") and ability["msg"] is String:
		return ability["msg"]
	return ""


static func server_card(title: String) -> Dictionary:
	return NRCardDefs.server_card(title)


static func used_this_turn(cid: String, state: NRState) -> bool:
	var per = state.getv("per-turn", {})
	return per is Dictionary and per.has(cid)


static func ability_context(targets: Variant) -> Dictionary:
	if targets is Dictionary:
		return targets
	if targets is Array and targets.size() > 0 and targets[0] is Dictionary:
		return targets[0]
	return {}
