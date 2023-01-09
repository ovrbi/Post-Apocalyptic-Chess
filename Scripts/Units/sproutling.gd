extends "res://Scripts/unit.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

func get_attacks():
	var ans = []
	var delta = Vector2i(1,0)
	for i in range(4):
		delta = Vector2i((-1)*delta.y, delta.x)
		if tilemap.is_in_map(tilemap.local_to_map(position)+delta): ans.append(tilemap.local_to_map(position)+delta)
	return ans
func preview_attacks(loc:Vector2i):
	return [loc]
func attack(loc:Vector2i): 
	do_damage(loc, tilemap.local_to_map(position))
	state = 2
	tilemap.select(null)

func die():
	tilemap.summon(tilemap.local_to_map(position),6)
	queue_free()
