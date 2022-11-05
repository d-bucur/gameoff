extends Character

class_name Barrel

@export var explosion_template: PackedScene

func _die():
	emit_signal("has_died")
	print("%s killed" % self)
	queue_free()
	var explosion = explosion_template.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	