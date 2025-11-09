extends Node

## Single source of truth for game state management.
##
## Manages state transitions, pause/resume, match lifecycle, and character registry.
## All state changes emit events through EventBus for other systems to react.

enum GameState {
	MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER,
	TRANSITIONING
}

var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.MENU

# Match data
var match_in_progress: bool = false
var match_winner: CharacterController = null
var current_level_path: String = ""

# Character registry
var registered_characters: Dictionary = {}  # CharacterController -> CharacterInfo

class CharacterInfo:
	var controller: CharacterController
	var spawn_point: Vector2
	var score: int = 0
	var is_alive: bool = true
	var respawn_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputManager.pause_toggled.connect(_on_pause_toggled)
	
	# Listen to character events
	EventBus.character_killed.connect(_on_character_killed)
	EventBus.win_condition_met.connect(_on_win_condition_met)

## Main state transitions

## Starts a new match by loading the specified level.
func start_match(level_path: String) -> void:
	if current_state != GameState.MENU and current_state != GameState.GAME_OVER:
		push_warning("Cannot start match from state: %s" % GameState.keys()[current_state])
		return
	
	match_in_progress = true
	match_winner = null
	current_level_path = level_path
	registered_characters.clear()
	
	_change_state(GameState.LOADING)
	EventBus.scene_changing.emit(get_tree().current_scene.scene_file_path if get_tree().current_scene else "", level_path)
	
	get_tree().change_scene_to_file(level_path)
	await get_tree().process_frame
	
	_change_state(GameState.PLAYING)
	EventBus.level_loaded.emit(level_path)
	EventBus.match_started.emit()

## Pauses the game and shows pause menu via UIManager.
func pause_game() -> void:
	if current_state != GameState.PLAYING:
		return
	
	_change_state(GameState.PAUSED)
	get_tree().paused = true
	EventBus.game_paused.emit()

## Resumes the game and hides pause menu.
func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return
	
	_change_state(GameState.PLAYING)
	get_tree().paused = false
	EventBus.game_resumed.emit()

## Ends the match, removes characters, and shows game over screen.
func end_match(winner: CharacterController) -> void:
	if current_state != GameState.PLAYING:
		return
	
	match_in_progress = false
	match_winner = winner
	_change_state(GameState.GAME_OVER)
	
	# Remove all characters from the scene
	_remove_all_characters()
	
	get_tree().paused = true
	EventBus.match_ended.emit(winner)

func return_to_menu() -> void:
	match_in_progress = false
	match_winner = null
	registered_characters.clear()
	get_tree().paused = false
	
	_change_state(GameState.TRANSITIONING)
	EventBus.scene_changing.emit(current_level_path, "res://scenes/ui/start_menu.tscn")
	
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
	await get_tree().process_frame
	
	current_level_path = ""
	_change_state(GameState.MENU)

func restart_match() -> void:
	if current_level_path == "":
		push_warning("Cannot restart: no level path stored")
		return_to_menu()
		return
	
	var level_path := current_level_path
	_change_state(GameState.TRANSITIONING)
	get_tree().paused = false
	
	get_tree().change_scene_to_file(level_path)
	await get_tree().process_frame
	
	match_in_progress = true
	match_winner = null
	registered_characters.clear()
	_change_state(GameState.PLAYING)
	EventBus.level_loaded.emit(level_path)
	EventBus.match_started.emit()

## Character registration

func register_character(character: CharacterController) -> void:
	if registered_characters.has(character):
		return
	
	var info := CharacterInfo.new()
	info.controller = character
	info.spawn_point = character.global_position
	info.score = 0
	info.is_alive = true
	info.respawn_timer = 0.0
	
	registered_characters[character] = info

func unregister_character(character: CharacterController) -> void:
	registered_characters.erase(character)

func get_character_info(character: CharacterController) -> CharacterInfo:
	return registered_characters.get(character, null)

func get_character_score(character: CharacterController) -> int:
	var info := get_character_info(character)
	return info.score if info else 0

func add_score(character: CharacterController, amount: int) -> void:
	var info := get_character_info(character)
	if info:
		info.score += amount

## State queries

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED

func is_in_menu() -> bool:
	return current_state == GameState.MENU

func is_game_over() -> bool:
	return current_state == GameState.GAME_OVER

func can_pause() -> bool:
	return current_state == GameState.PLAYING

func can_show_dev_menu() -> bool:
	return current_state in [GameState.PLAYING, GameState.PAUSED]

## Internal

func _change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	previous_state = current_state
	current_state = new_state
	
	EventBus.game_state_changed.emit(
		GameState.keys()[previous_state],
		GameState.keys()[current_state]
	)

func _on_pause_toggled() -> void:
	# Don't allow pause in certain states
	if not can_pause() and current_state != GameState.PAUSED:
		return
	
	if current_state == GameState.PAUSED:
		resume_game()
	elif current_state == GameState.PLAYING:
		pause_game()

func _on_character_killed(killer: CharacterController, _victim: CharacterController) -> void:
	var killer_info := get_character_info(killer)
	if killer_info:
		killer_info.score += 1

func _on_win_condition_met(winner: CharacterController) -> void:
	end_match(winner)

func _remove_all_characters() -> void:
	# Get all characters and remove them
	var characters := get_tree().get_nodes_in_group("characters")
	for node in characters:
		if is_instance_valid(node):
			node.queue_free()
