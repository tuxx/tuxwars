extends Node

## Central event bus for decoupled communication across systems.
##
## All game events are emitted through this singleton to avoid tight coupling
## between systems. Systems can subscribe to events without knowing about each other.

## Game state events
signal game_paused
signal game_resumed
signal game_state_changed(from_state: String, to_state: String)

## Match events
signal match_started
signal match_ended(winner: CharacterController)
signal win_condition_met(winner: CharacterController)
signal character_killed(killer: CharacterController, victim: CharacterController)

## Scene events
signal scene_changing(from_path: String, to_path: String)
signal scene_changed(scene_path: String)
signal level_loaded(level_path: String)

## UI events
signal ui_notification(message: String, type: String)
