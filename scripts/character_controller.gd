extends CharacterBody2D

# Movement and physics properties
@export var move_speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var is_player: bool = false
@export var character_color: Color = Color.WHITE
@export var max_fall_speed: float = 1000.0

# Respawn properties
var is_despawned: bool = false
var spawn_position: Vector2
var respawn_timer: float = 0.0
const RESPAWN_TIME: float = 2.0

# Animation
var animated_sprite: AnimatedSprite2D

func _ready():
	# Store initial spawn position
	spawn_position = global_position
	
	# Get animated sprite reference
	animated_sprite = get_node_or_null("AnimatedSprite2D")
	
	# Apply character color to visual representation if ColorRect exists
	var color_rect = get_node_or_null("ColorRect")
	if color_rect:
		color_rect.color = character_color

func _physics_process(delta: float) -> void:
	# Handle respawn timer
	if is_despawned:
		respawn_timer += delta
		if respawn_timer >= RESPAWN_TIME:
			_respawn()
		return
	
	# Handle input for player characters
	if is_player:
		_handle_input()
	
	# Apply gravity
	_apply_gravity(delta)
	
	# Cap velocity to prevent infinite acceleration
	velocity.y = clamp(velocity.y, -max_fall_speed, max_fall_speed)
	velocity.x = clamp(velocity.x, -move_speed * 2, move_speed * 2)
	
	# Move and handle collisions
	var previous_velocity_y = velocity.y
	move_and_slide()
	
	# Update animations
	_update_animation()
	
	# Check for head stomps
	if previous_velocity_y > 0:  # Was falling
		_check_head_stomp()

func _handle_input() -> void:
	# Horizontal movement input
	var input_direction = Input.get_axis("move_left", "move_right")
	velocity.x = input_direction * move_speed
	
	# Jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _apply_gravity(delta: float) -> void:
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity.y += gravity * delta

func _update_animation() -> void:
	if not animated_sprite:
		return
	
	# Determine which animation to play
	if abs(velocity.x) > 10:  # Moving horizontally
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
		
		# Flip sprite based on direction
		if velocity.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
	else:  # Idle
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func _check_head_stomp() -> void:
	# Check if we landed on another character
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if collider is a CharacterBody2D with the character_controller script
		if collider is CharacterBody2D and collider.has_method("despawn"):
			# Check if we're above the other character (stomping on head)
			if global_position.y < collider.global_position.y:
				collider.despawn()
				# Bounce the stomper
				velocity.y = jump_velocity * 0.5

func despawn() -> void:
	if is_despawned:
		return
	
	is_despawned = true
	respawn_timer = 0.0
	
	# Hide the character
	visible = false
	
	# Disable collision
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _respawn() -> void:
	is_despawned = false
	respawn_timer = 0.0
	
	# Reset position
	global_position = spawn_position
	velocity = Vector2.ZERO
	
	# Show the character
	visible = true
	
	# Enable collision
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
