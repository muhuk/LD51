extends KinematicBody

onready var state_machine = $StateMachine
onready var pivot = $Pivot
onready var eye_mesh = $Pivot/EyeMesh
onready var viewcone_mesh = $Pivot/Viewcone/Cone
onready var ray = $Pivot/RayCast
onready var anim_player = $AnimationPlayer
onready var tween = $Tween

onready var initial_rotation = self.rotation_degrees

export var angle_cone_of_vision := deg2rad(30.0)
export var max_view_distance :=  40.0
export var angle_between_rays := deg2rad(5.0)

var idle_colour = Color.chartreuse
var tracking_colour = Color.darkorange
var alert_colour = Color.crimson

var has_seen_player = false setget set_has_seen_player
var target: PlayerController = null

var debug_trajectory_meshes = []

#
#func _ready():
#	generate_raycasts()


func _physics_process(_delta):
	if has_seen_player == true:
		pivot.look_at(target.global_transform.origin, self.global_transform.basis.y)
		pivot.rotate_object_local(Vector3(0,1,0), 3.14)


func generate_debug_trajectory(trajectory_points, size):
	if not GlobalFlags.SHOW_DEBUG_TRAJECTORIES:
		return
	
	clear_debug_trajectory()
	# Get scene root
	var scene_root = get_tree().root.get_children()[0]
	for _point in trajectory_points:
		# Create sphere with low detail of size.
		var sphere = SphereMesh.new()
		sphere.radial_segments = 8
		sphere.rings = 8
		sphere.radius = size
		sphere.height = size * 2
		# Bright red material (unshaded).
		var material = SpatialMaterial.new()
		material.albedo_color = Color(1, 0, 0)
		material.flags_unshaded = true
		sphere.surface_set_material(0, material)
		
		# Add to meshinstance in the right place.
		var node = MeshInstance.new()
		node.mesh = sphere
		if node.is_inside_tree():
			node.global_transform.origin = _point
		scene_root.add_child(node)
		debug_trajectory_meshes.append(node)


func clear_debug_trajectory():
	for mesh in debug_trajectory_meshes:
		mesh.queue_free()
	debug_trajectory_meshes = []


func _on_Viewcone_body_entered(body):
	if body is PlayerController:
#		pivot.look_at(body.global_transform.origin, self.global_transform.basis.y)
#		pivot.rotate_object_local(Vector3(0,1,0), 3.14)
#		var local = ray.to_local(target.global_transform.origin)
#		ray.cast_to = local
		target = body
		set_has_seen_player(true)


func _on_Viewcone_body_exited(body):
	if body is PlayerController:
		target = null
		set_has_seen_player(false)


func set_has_seen_player(value):
	has_seen_player = value
	match has_seen_player:
		true:
			state_machine.transition_to("StateMachine/Tracking")
			anim_player.stop()
#			if ray.is_colliding():
#				if ray.get_collider() is PlayerController:
#					target = ray.get_collider()
#				else:
#					has_seen_player = false
		false:
			if not tween.is_inside_tree():
				return
			state_machine.transition_to("StateMachine/Idle")
			tween.interpolate_property(
				pivot, "rotation_degrees",
				pivot.rotation_degrees, Vector3.ZERO,
				2.0,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT
			)
			tween.start()
			yield(tween, "tween_completed")
			anim_player.play("rotate")

