class_name ChiribogaClient
extends Node

var base_url := "http://127.0.0.1:1043"
var last_error := ""
var _http: HTTPRequest


func _ready() -> void:
	if OS.get_environment("CHIRIBOGA_URL") != "":
		base_url = OS.get_environment("CHIRIBOGA_URL").rstrip("/")
	_http = HTTPRequest.new()
	_http.timeout = 45.0
	_http.use_threads = true
	add_child(_http)


func status() -> Dictionary:
	return await _req(HTTPClient.METHOD_GET, "/chiriboga/status")


func catalog() -> Dictionary:
	return await _req(HTTPClient.METHOD_GET, "/chiriboga/catalog")


func preview() -> Dictionary:
	return await _req(HTTPClient.METHOD_GET, "/chiriboga/preview")


func new_game(payload: Dictionary) -> Dictionary:
	return await _req(HTTPClient.METHOD_POST, "/chiriboga/new", payload)


func get_state(id: String) -> Dictionary:
	return await _req(HTTPClient.METHOD_GET, "/chiriboga/state?id=%s" % id.uri_encode())


func action(id: String, act: Dictionary) -> Dictionary:
	var body: Dictionary = act.duplicate(true)
	body["id"] = id
	return await _req(HTTPClient.METHOD_POST, "/chiriboga/action", body)


func _req(method: int, path: String, payload: Variant = null) -> Dictionary:
	last_error = ""
	if _http == null:
		last_error = "HTTPRequest missing"
		return {"ok": false, "error": last_error}
	var headers := PackedStringArray(["Accept: application/json", "Content-Type: application/json"])
	var body := ""
	if payload != null:
		body = JSON.stringify(payload)
	var err := _http.request(base_url + path, headers, method, body)
	if err != OK:
		last_error = "HTTP request error %s" % err
		return {"ok": false, "error": last_error}
	var completed: Array = await _http.request_completed
	var result: int = int(completed[0])
	var code: int = int(completed[1])
	var raw: PackedByteArray = completed[3]
	var text := raw.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS:
		last_error = "HTTP result %s" % result
		return {"ok": false, "error": last_error, "http": code}
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var d: Dictionary = parsed
		if code >= 400:
			d["ok"] = false
			if not d.has("error"):
				d["error"] = "HTTP %s" % code
		return d
	last_error = "bad JSON (%s): %s" % [code, text.substr(0, 180)]
	return {"ok": false, "error": last_error, "http": code}
