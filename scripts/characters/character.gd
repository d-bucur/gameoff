extends Actor

class_name Character

signal path_changed

@export var ai_debug_visible = false
@export var speed: float

@onready var _sprite = $Sprite
@onready var _navigation = $NavigationAgent2D

var _things_in_range: Dictionary = {}

var _moving_towards_target = false

func _physics_process(delta):
	# pathfinding movement
	if _moving_towards_target:
		_navigate_towards_target(delta)

func debug_ai_state(debug_text: String):
	if ai_debug_visible:
		print("AI: %s" % debug_text)

func _on_sprite_animation_finished() -> void:
	# using this instead of controller for simplicity
	if _sprite.animation == "fire":
		_sprite.play("idle")
	

# NAVIGATION
func change_target_destination(new_target: Vector2):
	_navigation.set_target_location(new_target)
	_navigation.get_next_location()
	emit_signal("path_changed")

func resume_movement():
	_moving_towards_target = true

func stop_movement():
	_moving_towards_target = false

func has_reached_target() -> bool:
	return _navigation.is_target_reached()

func _navigate_towards_target(delta):
	if has_reached_target():
		_sprite.animation = "idle"
		return
	var next = _navigation.get_next_location()
	var towards_next = next - global_position
	_move_towards(towards_next, delta)
	
func _move_towards(direction: Vector2, delta: float):
	if direction.length() > 1:
		direction = direction.normalized()
	direction *= speed * delta
	if direction.length() > 0:
		# _navigation.set_velocity(direction) # collision avoidance not wokring properly. disabling
		_do_move(direction)
	else: 
		_sprite.animation = "idle"

func _do_move(direction):
	velocity = direction
	move_and_slide()
	_sprite.flip_h = direction.x < 0
	if _sprite.animation != "walk":
		_sprite.animation = "walk"

# TARGETING
func get_item_in_range(item_type: String):
	if _things_in_range.has(item_type):
		for k in _things_in_range.get(item_type).keys():
			var value = _things_in_range.get(item_type)[k]
			if is_instance_valid(value):
				return value
			else:
				_things_in_range.get(item_type).erase(k)
	return null

func _node_to_type(node: Node2D):
	if node.is_in_group("player"):
		return "player"
	if node.is_in_group("enemy"):
		return "enemy"
	if node.is_in_group("ammo_pickup"):
		return "ammo"
	if node.is_in_group("health_pickup"):
		return "health"
	if node.is_in_group("barrel"):
		return "barrel"
	return null

func _map_type(type_name): # TODO rename
	return type_name

func _on_visibility_area_body_entered(body: Node2D) -> void:
	var type = _map_type(_node_to_type(body))
	if type == null:
		return
	if not _things_in_range.has(type):
		_things_in_range[type] = {}
	_things_in_range[type][body.get_instance_id()] = body

func _on_visibility_area_body_exited(body: Node2D) -> void:
	var type = _map_type(_node_to_type(body))
	if type == null:
		return
	if not _remember_type(type):
		_things_in_range[type].erase(body.get_instance_id())

func _remember_type(type: String) -> bool:
	return false

func _on_visibility_area_area_exited(area:Area2D) -> void:
	_on_visibility_area_body_exited(area.get_parent())

func _on_visibility_area_area_entered(area:Area2D) -> void:
	_on_visibility_area_body_entered(area.get_parent())
