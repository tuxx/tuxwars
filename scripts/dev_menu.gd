extends Control

func _ready() -> void:
	# Only show in debug builds (disabled in release exports)
	if not OS.is_debug_build():
		queue_free()
		return

	# Full-rect root to let containers position panel at top-right with margins
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	add_child(margin)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)
	# Push content to the right
	hbox.alignment = BoxContainer.ALIGNMENT_END

	var panel: PanelContainer = PanelContainer.new()
	panel.modulate.a = 0.7  # slightly transparent
	hbox.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Developer"
	vbox.add_child(title)

	var hint: Label = Label.new()
	hint.text = "K: Kill player"
	vbox.add_child(hint)

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_K:
			_kill_player()

func _kill_player() -> void:
	var player: Node = _get_player()
	if player and player.has_method("despawn"):
		player.despawn()

func _get_player() -> Node:
	# Prefer group lookup for robustness
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	# Fallback: try to find by common name
	var root: Node = get_tree().current_scene
	if root and root.has_node("PlayerCharacter"):
		return root.get_node("PlayerCharacter")
	return null
