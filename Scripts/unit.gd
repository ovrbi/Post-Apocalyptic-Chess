extends AnimatedSprite2D

const speed = 1000
@export var type : int #0:player side 1:enemy 2:neutral (no one controls)
var state : int #0:base 1:has moved 2:has attacked (player controlled only)
@export var passable : bool
@export var maxhp : int
var curhp :int
var borderlands = 1 #0:no 1:extra turn 2:revive on kill
@export var move_amount : int
@export var damage : int
var tilemap : TileMap
var movequeue = []
@export_multiline var desc
@export var subtype : int
var rooted = false
var atk_dir
var alpha_amount = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_parent()

	curhp = maxhp
	if type == 0:
		modulate.a = alpha_amount
		tilemap.friendlies_alive+=1
	update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !movequeue.is_empty():
		if position.distance_to(tilemap.map_to_local(movequeue[0]))<speed * delta:
			position = tilemap.map_to_local(movequeue[0])
			movequeue.pop_front()
			if movequeue.is_empty():
				if type == 0:
					tilemap.select(self)
				elif type ==2:
					tilemap.try_fertilize(tilemap.local_to_map(position))
				elif type==1:
					if atk_dir != Vector2i(0,0):
						attack(tilemap.local_to_map(position)+atk_dir)
					tilemap.process_next()
				tilemap.prev_cursor_loc = null
				tilemap.input_lock -=1
		else:
			position += (tilemap.map_to_local(movequeue[0])-position).normalized()*speed*delta

func get_attacks():
	return []
func preview_attacks(loc:Vector2i):
	return []
func attack(loc:Vector2i): 
	pass
func do_damage(loc:Vector2i, from:Vector2i):
	if tilemap.attack_tile(loc, from, damage+tilemap.wrath*int(type==0)) && type==0 && curhp<=0 && borderlands==2:
		curhp = 1

func autopilot():
	atk_dir = Vector2i(0,0)
	var alllocs = get_moves()
	if subtype == 2:
		for i in alllocs:
			var check = check_all_adjacent(i,true)
			if check>0:
				if check >= 8: atk_dir=Vector2i(0,-1)
				elif check >= 4: atk_dir=Vector2i(0,1)
				elif check >= 2: atk_dir=Vector2i(-1,0)
				else: atk_dir=Vector2i(1,0)
				move_to(i)
				return
	for i in alllocs:
		var check = check_all_adjacent(i,false)
		if check>0:
			if check >= 8: atk_dir=Vector2i(0,-1)
			elif check >= 4: atk_dir=Vector2i(0,1)
			elif check >= 2: atk_dir=Vector2i(-1,0)
			else: atk_dir=Vector2i(1,0)
			move_to(i)
			return
	move_to(alllocs[randi()%alllocs.size()])

func check_all_adjacent(loc:Vector2i, plant:bool):
	var ans = 0
	ans += int(check_adjacent(loc+Vector2i(1,0),plant))*1
	ans += int(check_adjacent(loc+Vector2i(-1,0),plant))*2
	ans += int(check_adjacent(loc+Vector2i(0,1),plant))*4
	ans += int(check_adjacent(loc+Vector2i(0,-1),plant))*8
	return ans
func check_adjacent(loc:Vector2i, plant:bool):
	if !tilemap.is_in_map(loc): return false
	if plant:
		return tilemap.has_neutral(loc, 1)
	else:
		return tilemap.check_friendly(loc) && tilemap.get_units(loc)[0].curhp>0

func die():
	if type==0:
		tilemap.friendlies_alive-=1
		if tilemap.friendlies_alive<=0:
#			print(get_tree().change_scene_to_packed(preload("res://Scenes/unit.tscn")))
			get_node("/root").add_child(preload("res://Scenes/lose_screen.tscn").instantiate())
			tilemap.input_lock+=1
	queue_free()

func move_to(to : Vector2i):
	tilemap.input_lock +=1
	var locs = []
	var to_process = [tilemap.local_to_map(position)]
	var locs_prev = []
	var proc_prev = [null]
	while !to_process.is_empty()&&to_process[0]!=to:
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
		if proc_prev.size() <=1:
			to_process=[]
			break
		to_process.pop_front()
		proc_prev.pop_front()
	if to_process.is_empty():
		tilemap.input_lock -=1
	else:
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
	var moves = [move_amount+tilemap.ms_boost*int(type==1)]
	if rooted: moves = [0]
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

func takedamage(amount:int, from : Vector2i): #returns true if lethal
	curhp -= amount
	update_label()
	if curhp <= 0:
		curhp =0
		if type != 0 || borderlands ==0:
			die()
			return true
	return false

func update_label():
	if type!=2:
		$Label.text = str(curhp)+"/"+str(maxhp)
