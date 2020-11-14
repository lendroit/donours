extends Node2D

onready var player = $Elements/Player
onready var mayans = $Elements/Mayans
onready var dropOffrandeArea = $DropOffrandeArea
onready var endOfGameLabel = $Gui/EndOfGameLabel
onready var replayButton = $Gui/EndOfGameLabel/Button

var number_of_angry_mayans = 0
var number_of_guards = 0

signal guard_is_trigered

func _on_new_angry_mayan():
	number_of_angry_mayans += 1
	print(number_of_angry_mayans)
	if number_of_angry_mayans%5 == 0:
		for child in mayans.get_children():
			if (child.isGuard) and (child.angriness < child.MAX_ANGRINESS_BEFORE_ITS_TOO_LATE):
				child.angriness = 2.0
				child.furthest_distance_ever = 50000
				break
				
		emit_signal("guard_is_trigered")
		print("guard pas content")

# Called when the node enters the scene tree for the first time.
func _ready():
	dropOffrandeArea.connect('body_entered', self, "_body_entered_drop_zone")
	player.connect('player_won', self, "_player_won")
	player.connect('player_died', self, "_player_died")
	replayButton.connect("pressed", self, "_restart_game")
	for child in mayans.get_children():
		var maya = child as GenericMayan
		maya.connect("got_angry", self, "_on_new_angry_mayan")
		maya.player = player
	for child in mayans.get_children():
		if child.isGuard:
			number_of_guards += 1
	
func _body_entered_drop_zone(body):
	if(body == player):
		player.has_entered_drop_area()

func _player_won():
	endOfGameLabel.text = 'BRAVO'
	endOfGameLabel.visible = true

func _player_died():
	endOfGameLabel.text = 'OHH !'
	endOfGameLabel.visible = true

func _restart_game():
	get_tree().reload_current_scene()
