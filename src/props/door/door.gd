extends Spatial

onready var anim_player = $AnimationPlayer

var can_interact = false

export (bool) var is_open = false setget set_is_open
export (bool) var is_sealed = false


func _ready():
	yield(owner, "ready")
	set_is_open(is_open)


func _input(event):
	if not can_interact or is_sealed:
		return
	if event.is_action_pressed("interact"):
		match is_open:
			false:
				anim_player.play("opening")
			true:
				anim_player.play("closing")


func _on_Area_body_entered(body):
	if is_sealed or not GlobalFlags.PLAYER_CONTROLS_ACTIVE:
		return
	if body is PlayerController:
		can_interact = true
		body.hud.animation_player.play("show_interact")


func _on_Area_body_exited(body):
	if is_sealed or not GlobalFlags.PLAYER_CONTROLS_ACTIVE:
		return
	if body is PlayerController:
		can_interact = false
		body.hud.animation_player.play("hide_interact")


func set_is_open(value):
	is_open = value
	if not anim_player:
		return
	match is_open:
		true:
			anim_player.play("open")
		false:
			anim_player.play("close")
