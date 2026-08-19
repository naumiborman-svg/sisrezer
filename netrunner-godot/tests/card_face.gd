class_name NRCardFace
extends Control
## Printable Netrunner card face. Data comes from NRCardDefs at runtime
## (printed `text` / cost / faction / type) — nothing is hardcoded.

enum Mode { SPOTLIGHT, HISTORY, TINY }

const FONT_PATH := "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"

var _mode: int = Mode.SPOTLIGHT
var _cdef: Dictionary = {}
var _mono: Font
var _frame: ColorRect
var _inner: ColorRect
var _stripe: ColorRect
var _cost_bg: ColorRect
var _cost_lbl: Label
var _title: Label
var _type_lbl: Label
var _kw: Label
var _body: Label
var _side_tag: Label


func configure(cdef: Dictionary, font: Font, mode: int = Mode.SPOTLIGHT) -> void:
	_cdef = cdef
	_mono = font if font != null else _load_mono()
	_mode = mode
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	match mode:
		Mode.SPOTLIGHT:
			custom_minimum_size = Vector2(420, 560)
			size = Vector2(420, 560)
		Mode.HISTORY:
			custom_minimum_size = Vector2(148, 196)
			size = Vector2(148, 196)
		Mode.TINY:
			custom_minimum_size = Vector2(108, 78)
			size = Vector2(108, 78)
	if _frame == null:
		_build()
	_paint()


func _load_mono() -> Font:
	if FileAccess.file_exists(FONT_PATH):
		var ff := FontFile.new()
		if ff.load_dynamic_font(FONT_PATH) == OK:
			return ff
	return ThemeDB.fallback_font


func _build() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_frame = ColorRect.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)

	_inner = ColorRect.new()
	_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_inner)

	_stripe = ColorRect.new()
	_stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stripe)

	_cost_bg = ColorRect.new()
	_cost_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cost_bg)

	_cost_lbl = Label.new()
	_cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_cost_lbl)

	_title = Label.new()
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_title)

	_type_lbl = Label.new()
	add_child(_type_lbl)

	_kw = Label.new()
	_kw.autowrap_mode = TextServer.AUTOWRAP_OFF
	_kw.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(_kw)

	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_body)

	_side_tag = Label.new()
	_side_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_side_tag)


func _paint() -> void:
	var w := size.x if size.x > 1.0 else custom_minimum_size.x
	var h := size.y if size.y > 1.0 else custom_minimum_size.y
	var frame_col := faction_color(_cdef)
	var inner_col := _inner_color(_cdef)
	var pad := 8.0 if _mode == Mode.SPOTLIGHT else (5.0 if _mode == Mode.HISTORY else 3.0)
	_frame.color = frame_col
	_frame.position = Vector2.ZERO
	_frame.size = Vector2(w, h)
	_inner.color = inner_col
	_inner.position = Vector2(pad, pad)
	_inner.size = Vector2(w - pad * 2.0, h - pad * 2.0)

	var stripe_h := 6.0 if _mode == Mode.SPOTLIGHT else 4.0
	_stripe.color = frame_col.lightened(0.15)
	_stripe.position = Vector2(pad, pad)
	_stripe.size = Vector2(w - pad * 2.0, stripe_h)

	var cost_d := 54.0 if _mode == Mode.SPOTLIGHT else (28.0 if _mode == Mode.HISTORY else 20.0)
	_cost_bg.color = Color(0.06, 0.07, 0.09, 0.95)
	_cost_bg.position = Vector2(pad + 6.0, pad + stripe_h + 6.0)
	_cost_bg.size = Vector2(cost_d, cost_d)
	_cost_lbl.position = _cost_bg.position
	_cost_lbl.size = _cost_bg.size
	_cost_lbl.text = _cost_text(_cdef)
	_apply_font(_cost_lbl, 22 if _mode == Mode.SPOTLIGHT else (12 if _mode == Mode.HISTORY else 10), Color("f0c14b"))

	var title_x := _cost_bg.position.x + cost_d + 8.0
	var title_w := w - title_x - pad - 8.0
	var title_h := 64.0 if _mode == Mode.SPOTLIGHT else (36.0 if _mode == Mode.HISTORY else 28.0)
	_title.position = Vector2(title_x, pad + stripe_h + 4.0)
	_title.size = Vector2(title_w, title_h)
	_title.text = str(_cdef.get("title", "?"))
	_apply_font(_title, 18 if _mode == Mode.SPOTLIGHT else (11 if _mode == Mode.HISTORY else 9), Color("f4f7fb"))

	var type_y := _cost_bg.position.y + cost_d + (10.0 if _mode != Mode.TINY else 4.0)
	_type_lbl.position = Vector2(pad + 8.0, type_y)
	_type_lbl.size = Vector2(w - pad * 2.0 - 16.0, 22.0 if _mode == Mode.SPOTLIGHT else 14.0)
	_type_lbl.text = _type_line(_cdef)
	_apply_font(_type_lbl, 13 if _mode == Mode.SPOTLIGHT else 9, frame_col.lightened(0.25))

	if _mode == Mode.TINY:
		_kw.visible = false
		_body.visible = false
		_side_tag.visible = false
		return

	_kw.visible = true
	_body.visible = true
	_side_tag.visible = true
	var kw_y := type_y + (22.0 if _mode == Mode.SPOTLIGHT else 14.0)
	_kw.position = Vector2(pad + 8.0, kw_y)
	_kw.size = Vector2(w - pad * 2.0 - 16.0, 18.0 if _mode == Mode.SPOTLIGHT else 12.0)
	_kw.text = str(_cdef.get("keywords", "")).strip_edges()
	_apply_font(_kw, 12 if _mode == Mode.SPOTLIGHT else 8, Color("8b9bb4"))

	var body_y := kw_y + (24.0 if _mode == Mode.SPOTLIGHT else 14.0)
	var body_h := h - body_y - pad - (28.0 if _mode == Mode.SPOTLIGHT else 16.0)
	_body.position = Vector2(pad + 10.0, body_y)
	_body.size = Vector2(w - pad * 2.0 - 20.0, maxf(body_h, 24.0))
	_body.text = pretty_text(str(_cdef.get("text", "")).strip_edges())
	if _body.text == "":
		_body.text = _fallback_text(_cdef)
	_apply_font(_body, 14 if _mode == Mode.SPOTLIGHT else 9, Color("d7e3f4"))

	_side_tag.position = Vector2(pad + 8.0, h - pad - 22.0)
	_side_tag.size = Vector2(w - pad * 2.0 - 16.0, 18.0)
	_side_tag.text = str(_cdef.get("side", "")).to_upper()
	_apply_font(_side_tag, 11 if _mode == Mode.SPOTLIGHT else 8, frame_col)


func _apply_font(lbl: Label, px: int, col: Color) -> void:
	if _mono != null:
		lbl.add_theme_font_override("font", _mono)
	lbl.add_theme_font_size_override("font_size", px)
	lbl.add_theme_color_override("font_color", col)


static func faction_color(cdef: Dictionary) -> Color:
	var faction := str(cdef.get("faction", "Neutral"))
	var side := str(cdef.get("side", ""))
	if faction == "Neutral" or faction == "":
		return Color("8b9199")
	if side == "Runner":
		return Color("2ec4b6")
	return Color("e85d4c")


func _inner_color(cdef: Dictionary) -> Color:
	var typ := str(cdef.get("type", "")).to_lower()
	match typ:
		"ice":
			return Color("12182a")
		"agenda":
			return Color("2a2110")
		"operation", "event":
			return Color("1a1d22")
		"program":
			return Color("0e2422")
		"asset", "upgrade":
			return Color("2a1612")
		"hardware":
			return Color("1a2030")
		"identity":
			return Color("16141c")
		_:
			return Color("14181f")


func _cost_text(cdef: Dictionary) -> String:
	var typ := str(cdef.get("type", "")).to_lower()
	if typ == "identity":
		return "ID"
	if typ == "agenda":
		return str(int(cdef.get("advancementcost", cdef.get("advancement-requirement", 0))))
	if cdef.has("cost") and cdef.get("cost") != null:
		return str(int(cdef.get("cost", 0)))
	return "—"


func _type_line(cdef: Dictionary) -> String:
	var typ := str(cdef.get("type", "Card"))
	if typ.to_lower() == "agenda":
		return "%s  ·  %d AP" % [typ, int(cdef.get("agendapoints", cdef.get("agenda-point", 0)))]
	if typ.to_lower() == "ice" and cdef.has("strength"):
		return "%s  ·  STR %s" % [typ, str(cdef.get("strength"))]
	if typ.to_lower() == "program" and cdef.has("strength"):
		return "%s  ·  STR %s  MU %s" % [typ, str(cdef.get("strength")), str(cdef.get("memoryunits", cdef.get("memory-units", 1)))]
	return typ


static func pretty_text(raw: String) -> String:
	var t := raw
	t = t.replace("[credit]", "¢").replace("[Credits]", "¢").replace("[Credit]", "¢")
	t = t.replace("[click]", "●").replace("[Click]", "●")
	t = t.replace("[subroutine]", "◆ ")
	t = t.replace("[trash]", "TRASH")
	t = t.replace("[recurring-credit]", "¢r")
	t = t.replace("<em>", "").replace("</em>", "")
	t = t.replace("<strong>", "").replace("</strong>", "")
	t = t.replace("<b>", "").replace("</b>", "")
	t = t.replace("[b]", "").replace("[/b]", "")
	return t


func _fallback_text(cdef: Dictionary) -> String:
	var typ := str(cdef.get("type", "")).to_lower()
	if typ == "identity":
		return "Identity — %s\nDeck %s  ·  Influence %s" % [
			str(cdef.get("faction", "")),
			str(cdef.get("minimumdecksize", "?")),
			str(cdef.get("influencelimit", "?")),
		]
	return "(no printed text in registry)"
