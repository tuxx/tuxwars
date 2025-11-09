extends Control
class_name ScoreCounter

## Tracks and displays kill scores for all characters.
##
## Creates UI entries for each character with portrait and score, listens to
## character_killed events via EventBus, scales UI based on character count,
## and triggers win condition when a character reaches the target score.

const SCORE_ENTRY_SCENE := preload("res://scenes/ui/score_entry.tscn")
const GAME_OVER_SCENE := preload("res://scenes/ui/game_over_scoreboard.tscn")
const SCORE_FORMAT := "%d"
const MAX_SCORE := 999
const PORTRAIT_TARGET_SIZE := 28.0

# Scaling thresholds based on character count
const SCALE_NORMAL := 1.0      # 1-2 characters
const SCALE_SMALL := 0.85      # 3-4 characters
const SCALE_SMALLER := 0.70    # 5-6 characters
const SCALE_TINY := 0.60       # 7+ characters

@onready var _entries_container: HBoxContainer = $"Entries"

var _entries_by_character: Dictionary = {}
var _portrait_cache: Dictionary = {}

func _ready() -> void:
	add_to_group("score_counter")
	call_deferred("_scan_existing_characters")
	get_tree().node_added.connect(_on_node_added)
	
	# Listen to EventBus for character kills
	EventBus.character_killed.connect(_on_character_killed_event)

func _scan_existing_characters() -> void:
	var characters: Array = []
	for node in get_tree().get_nodes_in_group("characters"):
		if node is CharacterController:
			characters.append(node)
	characters.sort_custom(Callable(self, "_character_sort"))
	for character in characters:
		_register_character(character)

func _character_sort(a: CharacterController, b: CharacterController) -> bool:
	if a.is_player != b.is_player:
		return a.is_player and not b.is_player
	return a.name < b.name

func _on_node_added(node: Node) -> void:
	if node is CharacterController:
		_register_character(node)

func _register_character(character: CharacterController) -> void:
	if _entries_by_character.has(character):
		return
	var entry := _create_entry_ui()
	_entries_container.add_child(entry.node)
	_entries_by_character[character] = entry
	_update_entry_portrait(character, entry)
	_update_entry_label(entry)
	character.tree_exiting.connect(_on_character_tree_exiting.bind(character))
	
	# Update scale based on total character count
	_update_scale()

func _create_entry_ui() -> Dictionary:
	var node := SCORE_ENTRY_SCENE.instantiate() as Control
	var portrait := node.get_node("HBoxContainer/Portrait") as TextureRect
	var score_label := node.get_node("HBoxContainer/ScoreLabel") as Label
	return {
		"node": node,
		"portrait": portrait,
		"label": score_label,
		"score": 0
	}

func _update_entry_portrait(character: CharacterController, entry: Dictionary) -> void:
	var portrait: TextureRect = entry.get("portrait")
	if portrait == null or character == null:
		return
	var texture: Texture2D = _get_character_portrait_texture(character)
	if texture == null:
		texture = _get_sprite_frame_texture(character)
	if texture:
		portrait.texture = texture
	
	# Apply character's color tint to the portrait
	portrait.modulate = character.character_color

func _get_character_portrait_texture(character: CharacterController) -> Texture2D:
	if character == null:
		return null
	var asset_name := character.character_asset_name if character.character_asset_name else ""
	if asset_name.is_empty():
		return null
	var path := ResourcePaths.get_character_portrait_path(asset_name)
	if _portrait_cache.has(path):
		return _portrait_cache[path]
	if not ResourceLoader.exists(path):
		_portrait_cache[path] = null
		return null
	var texture := load(path)
	if texture is Texture2D:
		_portrait_cache[path] = texture
		return texture
	_portrait_cache[path] = null
	return null

func _get_sprite_frame_texture(character: CharacterController) -> Texture2D:
	var sprite := character.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		return null
	var frames := sprite.sprite_frames
	if frames == null:
		return null
	if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
		return frames.get_frame_texture("idle", 0)
	var animation_names := frames.get_animation_names()
	if animation_names.size() == 0:
		return null
	var first_animation := animation_names[0]
	if frames.get_frame_count(first_animation) == 0:
		return null
	return frames.get_frame_texture(first_animation, 0)

func _on_character_killed_event(killer: CharacterController, _victim: CharacterController) -> void:
	_add_score(killer, 1)

func _add_score(character: CharacterController, amount: int) -> void:
	if not _entries_by_character.has(character):
		return
	var entry: Dictionary = _entries_by_character[character]
	entry["score"] = clampi(entry.get("score", 0) + amount, 0, MAX_SCORE)
	_update_entry_label(entry)
	
	# Check win condition
	_check_win_condition(character, entry["score"])

func _update_entry_label(entry: Dictionary) -> void:
	var label: Label = entry.get("label")
	if label == null:
		return
	var score_value := int(entry.get("score", 0))
	var formatted := SCORE_FORMAT % score_value
	label.text = formatted

func _on_character_tree_exiting(character: CharacterController) -> void:
	if not _entries_by_character.has(character):
		return
	var entry: Dictionary = _entries_by_character[character]
	_entries_by_character.erase(character)
	var node: Control = entry.get("node")
	if node:
		node.queue_free()
	
	# Update scale after removing a character
	_update_scale()


func _update_scale() -> void:
	# Scale down the score counter based on number of entries
	var count := _entries_by_character.size()
	var target_scale: float
	
	if count <= 2:
		target_scale = SCALE_NORMAL
	elif count <= 4:
		target_scale = SCALE_SMALL
	elif count <= 6:
		target_scale = SCALE_SMALLER
	else:
		target_scale = SCALE_TINY
	
	# Apply scale to the entire score counter
	scale = Vector2(target_scale, target_scale)

func _check_win_condition(character: CharacterController, score: int) -> void:
	var kills_to_win := GameSettings.get_kills_to_win()
	if score >= kills_to_win:
		# Someone won! Emit event for GameStateManager to handle
		EventBus.win_condition_met.emit(character)


func get_character_score(character: CharacterController) -> int:
	if _entries_by_character.has(character):
		var entry: Dictionary = _entries_by_character[character]
		return entry.get("score", 0)
	return 0
