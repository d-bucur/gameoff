extends Node

@export var camera_shake_intensity: float = 10.0
@export var camera_shake_duration: float = 0.1
@export var hitstop_intensity: float = 0.2
@export var hitstop_duration: float = 0.1

func _ready() -> void:
	GlobalEvents.connect("player_took_damage", _on_player_took_damage)
	GlobalEvents.connect("explosion_happened", _on_explosion_happened)

func shake_camera(intensity: float, duration: float):
	duration /= 2
	var _camera = Globals.player._camera
	var tween = get_tree().create_tween()
	tween.tween_property(_camera, "offset", Vector2(intensity, 0), duration/2)
	tween.tween_property(_camera, "offset", Vector2(-intensity, 0), duration)
	tween.tween_property(_camera, "offset", Vector2(0, 0), duration/2)

func hit_stop(intensity: float, duration: float):
	Engine.time_scale = intensity
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1

func _on_player_took_damage(damage: int, origin: Node2D):
	shake_camera(camera_shake_intensity, camera_shake_duration)
	hit_stop(hitstop_intensity, hitstop_duration)

func _on_explosion_happened(position: Vector2):
	var mult = 7
	shake_camera(camera_shake_intensity * mult, camera_shake_duration * mult)
	hit_stop(hitstop_intensity / mult, hitstop_duration * mult)