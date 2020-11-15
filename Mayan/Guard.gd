extends "res://Mayan/GenericMayan.gd"

var Spear = load("res://Mayan/Spear.tscn")

var throw_sounds = [
	preload("res://assets/Sounds/throw_01_session.wav"),
	preload("res://assets/Sounds/throw_02_session.wav"),
	preload("res://assets/Sounds/throw_03_session.wav"),
	preload("res://assets/Sounds/throw_04_session.wav"),
	preload("res://assets/Sounds/throw_05_session.wav"),
]

onready var music = $AudioStreamPlayer2D

var timer

func _init():
	timer = Timer.new()
	add_child(timer)
	timer.autostart = true
	randomize()
	timer.wait_time = 2 + rand_range(-0.5, 0.5)
	timer.connect("timeout", self, "_timeout")


func _timeout():
	if angriness > MAX_ANGRINESS_BEFORE_ITS_TOO_LATE:
		throw_spear()



func _ready():
	isGuard = true
	
	ACCEPTABLE_DISTANCE = 0 # max distance before mayans get angry
	MAX_DISTANCE = 3
	MAX_ANGRINESS_BEFORE_ITS_TOO_LATE = 1.1
	SPEED = 20

	# Initialize randomly delayed animation for each Mayan
	yield(get_tree().create_timer(rand_range(0, 1)), "timeout")
	animation_player.play("MayanIdle")


func throw_spear():
	_throw_spear_song()
	var direction_towards_player = _get_player_direction()
	var b = Spear.instance()
	b.position = self.global_position
	b.rotation = direction_towards_player.angle()
	get_node("/root/World").add_child(b)
	pass

func _throw_spear_song():
	var random_song = randi()%throw_sounds.size()
	music.stream = throw_sounds[random_song]
	music.play()
	
