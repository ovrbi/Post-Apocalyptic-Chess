extends "res://Scripts/unit.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	tilemap.try_fertilize(tilemap.local_to_map(position))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

func get_attacks():
	pass
func preview_attacks(loc:Vector2i):
	pass
func attack(loc:Vector2i): 
	pass
	


func takedamage(amount:int, from : Vector2i): #returns true if lethal
	move_to(tilemap.local_to_map(position)+tilemap.biggest_dimension(tilemap.local_to_map(position)-from))
	
