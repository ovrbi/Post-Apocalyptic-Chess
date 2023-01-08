extends "res://Scripts/unit.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

func get_attacks():
	pass
func preview_attacks(loc:Vector2i):
	pass
func attack(loc:Vector2i): 
	pass
	
func die():
	tilemap.summon(tilemap.local_to_map(position),6)
	queue_free()
