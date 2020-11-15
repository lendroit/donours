extends KinematicBody2D

export (int) var speed = 800
export (int) var push = 100
var ACCELERATION = 7000
var MAX_SPEED = 400
var FRICTION = 10000

var velocity = Vector2.ZERO
var item_held = null
var is_dead = false

var impact_sounds = [
	preload("res://assets/Sounds/impact_01_session.wav"),
	preload("res://assets/Sounds/impact_02_session.wav"),
	preload("res://assets/Sounds/impact_03_session.wav"),
]


var death_sounds = [
	preload("res://assets/Sounds/death_01_session.wav"),
	preload("res://assets/Sounds/death_02_session.wav"),
	preload("res://assets/Sounds/death_03_session.wav"),
	preload("res://assets/Sounds/death_04_session.wav"),
	preload("res://assets/Sounds/death_05_session.wav"),
	preload("res://assets/Sounds/death_06_session.wav"),
	preload("res://assets/Sounds/death_07_session.wav"),
	preload("res://assets/Sounds/death_08_session.wav"),
	preload("res://assets/Sounds/death_09_session.wav"),
]

onready var reachableObjectsArea = $ReachableObjectsArea
onready var animation_player = $AnimationPlayer
onready var picked_offrande = $PickedOffrande
onready var music = $AudioStreamPlayer

signal player_won
signal player_died
signal player_picked

func _ready():
	reachableObjectsArea.connect("body_entered", self, "_pickable_item_entered_area")

func _pickable_item_entered_area(item):
	if !is_dead:
		_pick_item(item)

func _pick_item(item: Node2D):
	emit_signal("player_picked")
	picked_offrande.visible = true
	ACCELERATION = 2500
	MAX_SPEED = 200
	FRICTION = 2000
	item_held = item
	item.visible = false

func _drop_item():
	print("etbah")
	picked_offrande.visible = false
	ACCELERATION = 7000
	MAX_SPEED = 400
	FRICTION = 10000
	item_held.position = position
	item_held.visible = true
	item_held = null

func has_entered_drop_area():
	if(item_held):
		_drop_item()
		emit_signal("player_won")

func has_been_hit(body):
	_play_hit_sound()
	body.queue_free()
	_die()

func _die():
	if !is_dead:
		_play_death_sound()
		animation_player.play("BearDeath")
		is_dead = true
		if item_held:
			_drop_item()
		emit_signal("player_died")


func _physics_process(delta):
	if is_dead:
		return

	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_vector.length() > 1:
		input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animation_player.play("BearWalks")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animation_player.play("BearIdle")
	
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, PI / 4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.get_collision_layer_bit(2):
			collision.collider.apply_central_impulse(-collision.normal * push)
			pass

func _play_hit_sound():
	var random_index = randi()%impact_sounds.size()
	music.stream = impact_sounds[random_index]
	music.play()

func _play_death_sound():
	var random_index = randi()%death_sounds.size()
	music.stream = death_sounds[random_index]
	music.play()
