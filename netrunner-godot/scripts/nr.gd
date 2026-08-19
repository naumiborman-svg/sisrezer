extends Node
## Autoload facade. Other scripts can use class_name modules directly; this Node
## exists so `NR` is available as a singleton in Godot scenes.

const VERSION = "0.1.0"
const SOURCE = "mtgred/netrunner (Jinteki.net Clojure core)"

func _ready() -> void:
	NRCardsBasic.register()
