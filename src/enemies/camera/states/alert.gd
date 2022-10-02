extends State


func enter(_msg := {}) -> void:
	_actor.eye_mesh.set_surface_material(1, _actor.alert_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.alert_transparent_mat)
	
	if _actor.has_seen_player:
		for turret_path in _actor.linked_turrets:
			var turret = _actor.get_node(turret_path)
			turret.target = _actor.target
			if not turret.is_active:
				turret.set_is_active(true)
			turret.state_machine.transition_to("Alert")


func update(delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	for turret_path in _actor.linked_turrets:
		var turret = _actor.get_node(turret_path)
		if turret.is_active:
			turret.set_is_active(false)
