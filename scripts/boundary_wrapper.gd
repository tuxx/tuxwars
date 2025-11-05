extends Node2D

# Boundary properties defining the wrap-around edges
@export var boundary_left: float = 0.0
@export var boundary_right: float = 1280.0
@export var boundary_top: float = 0.0
@export var boundary_bottom: float = 720.0

# Offset to prevent oscillation when wrapping
@export var wrap_offset: float = 10.0

# Called every frame to check for boundary wrapping
func _process(_delta: float) -> void:
	# Check all CharacterBody2D children in the parent node
	for child in get_parent().get_children():
		if child is CharacterBody2D:
			_check_wrap(child)

# Test if character position exceeds boundaries and wrap if needed
func _check_wrap(character: CharacterBody2D) -> void:
	_wrap_horizontal(character)
	_wrap_vertical(character)

# Handle left/right edge wrapping
func _wrap_horizontal(character: CharacterBody2D) -> void:
	if character.position.x > boundary_right:
		character.position.x = boundary_left + wrap_offset
	elif character.position.x < boundary_left:
		character.position.x = boundary_right - wrap_offset

# Handle top/bottom edge wrapping
func _wrap_vertical(character: CharacterBody2D) -> void:
	if character.position.y > boundary_bottom:
		character.position.y = boundary_top + wrap_offset
	elif character.position.y < boundary_top:
		character.position.y = boundary_bottom - wrap_offset
