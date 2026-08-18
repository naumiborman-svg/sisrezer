class_name Explosion
extends Node2D

var _age := 0.0
var _rings: Array[float] = [4.0, 9.0, 14.0]


func _ready() -> void:
	z_index = 30


func _process(delta: float) -> void:
	_age += delta
	queue_redraw()
	if _age > 0.35:
		queue_free()


func _draw() -> void:
	var t := clampf(_age / 0.35, 0.0, 1.0)
	var alpha := 1.0 - t
	for i in _rings.size():
		var r: float = _rings[i] + t * 18.0
		var color := Color("ffcc55") if i == 0 else Color("ff6622")
		color.a = alpha * (1.0 - float(i) * 0.2)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 18, color, 2.0)
	draw_circle(Vector2.ZERO, 3.0 + t * 6.0, Color(1, 1, 0.8, alpha))
