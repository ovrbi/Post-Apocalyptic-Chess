extends Sprite2D

const speed = 200
var type : int #0:player side 1:enemy 2:neutral (no one controls)
var state : int #0:base 1:has moved 2:has attacked (player controlled only)
var passable : bool
var maxhp : int
var curhp = maxhp
var borderlands = 1 #0:no 1:extra turn 2:revive on kill
var move_amount : int
var tilemap : TileMap
var movequeue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !movequeue.is_empty():
		if position.distance_to(tilemap.map_to_local(movequeue[0]))<speed * delta:
			position = tilemap.map_to_local(movequeue[0])
			movequeue.pop_front()
			if movequeue.is_empty():
				if type == 0:
					tilemap.input_lock = false
					tilemap.select(self)
				
		else:
			position += (tilemap.map_to_local(movequeue[0])-position).normalized()*speed*delta

func get_attacks():
	pass
func attack(loc:Vector2i): 
	pass

func move_to(to : Vector2i):
	tilemap.input_lock = true
	var locs = []
	var to_process = [tilemap.local_to_map(position)]
	var locs_prev = []
	var proc_prev = [null]
	while to_process[0]!=to:
		var delta = Vector2i(1,0)
		for i in range(4):
			delta = Vector2i((-1)*delta.y, delta.x)
			if locs.has(to_process[0]+delta): continue
			if to_process.has(to_process[0]+delta): continue
			if !tilemap.is_in_map(to_process[0]+delta): continue
			var unit = tilemap.get_units(to_process[0]+delta)
			if !unit.is_empty():
				if !unit[0].passable: continue
			to_process.append(to_process[0]+delta)
			proc_prev.append(locs_prev.size())
		locs.append(to_process[0])
		locs_prev.append(proc_prev[0])
		to_process.pop_front()
		proc_prev.pop_front()
	var target = proc_prev[0]
	var ans = [to_process[0]]
	while target != null:
		ans.push_front(locs[target])
		target = locs_prev[target]
	movequeue = ans
	tilemap.select(null)
	state = 1
	
func get_moves():
	var locs = []
	var to_process = [tilemap.local_to_map(position)]
	var moves = [move_amount]
	while !to_process.is_empty() && moves[0]>=0:
		var delta = Vector2i(1,0)
		for i in range(4):
			delta = Vector2i((-1)*delta.y, delta.x)
			if locs.has(to_process[0]+delta): continue
			if to_process.has(to_process[0]+delta): continue
			if !tilemap.is_in_map(to_process[0]+delta): continue
			var unit = tilemap.get_units(to_process[0]+delta)
			if !unit.is_empty():
				if !unit[0].passable: continue
			to_process.append(to_process[0]+delta)
			moves.append(moves[0]-1)
		locs.append(to_process[0])
		to_process.pop_front()
		moves.pop_front()
	return locs

func takedamage(amount:int):
	pass
