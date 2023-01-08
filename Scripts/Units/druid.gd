extends "res://Scripts/unit.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	type = 0
	state = 0
	passable = false
	maxhp = 3
	move_amount = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
