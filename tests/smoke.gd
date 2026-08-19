extends SceneTree


func _initialize() -> void:
	if CardLibrary.cards().is_empty() or CardLibrary.decks().is_empty():
		push_error("card data missing")
		quit(1)
		return
	var title_ps := load("res://scenes/title.tscn") as PackedScene
	var board_ps := load("res://scenes/board.tscn") as PackedScene
	var clojure_ps := load("res://scenes/clojure_board.tscn") as PackedScene
	if title_ps == null or board_ps == null or clojure_ps == null:
		push_error("scenes failed to load")
		quit(1)
		return
	var title := title_ps.instantiate()
	root.add_child(title)
	await process_frame
	title.queue_free()
	var board := board_ps.instantiate()
	board.set("mode", "hotseat")
	root.add_child(board)
	await create_timer(0.4).timeout
	if board.engine == null or board.engine.corp.hand.is_empty():
		push_error("board engine did not start")
		quit(1)
		return
	if board.engine.legal().is_empty():
		push_error("no legal actions at game start")
		quit(1)
		return
	print("SMOKE_OK")
	quit(0)
