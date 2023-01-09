extends TileMap

signal next_turn
signal change_hover
signal change_mode

const size = 8
var input_lock = 0
var mode = 0 #0:normal 1:plant 2:harvest
var harvestsize = 5
var selected : Node2D
var processqueue = []
@export var node_selector : Node2D
@export var node_selected : Node2D
var turn = 0
var points = 0
var can_harvest = true
var prev_cursor_loc 
var summon_units = [
	preload("res://Scenes/Units/druid.tscn"),			#0
	preload("res://Scenes/Units/sproutling.tscn"),		#1
	preload("res://Scenes/Units/thistle_slinger.tscn"),	#2
	preload("res://Scenes/Units/vine_ghoul.tscn"),		#3
	preload("res://Scenes/Units/lavender_mender.tscn"),	#4
	preload("res://Scenes/Units/monstrous_treant.tscn"),#5
	preload("res://Scenes/Units/sprout.tscn"),			#6
	preload("res://Scenes/Units/plant.tscn"),			#7
	preload("res://Scenes/Units/corpse.tscn"),			#8
	preload("res://Scenes/Units/foot_soldier.tscn"),	#9
	preload("res://Scenes/Units/cavalry.tscn"),			#10
	preload("res://Scenes/Units/arsonist.tscn"),		#11
	preload("res://Scenes/Units/battle_drummer.tscn"),	#12
	preload("res://Scenes/Units/sweeper.tscn"),			#13
	preload("res://Scenes/Units/war_leader.tscn")		#14
]

var wrath = 0
var ms_boost = 0
var extra_attack = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	selected = null
	prev_cursor_loc = null
	summon(Vector2i(2,2),0)
	summon(Vector2i(3,2),0)
	summon(Vector2i(2,3),0)
	summon(Vector2i(3,3),0)
	#spawn initial enemies
	end_turn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouseloc = local_to_map(get_viewport().get_mouse_position()-position)
	if mouseloc != prev_cursor_loc:
		if mouseloc.x>=0&&mouseloc.y>=0&&mouseloc.x<size &&mouseloc.y<size:
			node_selector.visible=true
			node_selector.position=map_to_local(mouseloc)
			if mode==2:
				clear_layer(1)
				var places = get_harvest(mouseloc,harvestsize)
				for i in places:
					if has_neutral(i,1):
						set_cell(1,i,0,Vector2i(0,1))
					else:
						set_cell(1,i,0,Vector2i(0,0))
		else:
			node_selector.visible=false
		if selected != null && selected.type == 0 && selected.state == 1:
			clear_layer(2)
			if get_cell_source_id(1,mouseloc)!=-1:
				var places = selected.preview_attacks(mouseloc)
				for i in places:
					set_cell(2,i,0,Vector2i(0,0))
		emit_signal("change_hover")
		prev_cursor_loc = mouseloc

func _unhandled_input(event : InputEvent):
	if input_lock==0:
		if event.is_action_pressed("LeftClick"):
			var mouseloc = local_to_map(get_viewport().get_mouse_position()-position)
			var mouse_t = get_units(mouseloc)
			if mode == 0:
				if get_cell_source_id(1,mouseloc)==-1:
					if mouse_t.is_empty():
						select(null)
					else:
						if mouse_t[0] == selected:
							if mouse_t.size()>1:
								select(mouse_t[1])
						else:
							select(mouse_t[0])
				else:
					if selected.state == 0:
						selected.move_to(mouseloc)
					else:
						selected.attack(mouseloc)
			elif mode == 1:
				if get_cell_source_id(1,mouseloc)!=-1:
					summon(mouseloc,6)
					mode = 0
					can_harvest = false
					select(null)
			elif mode == 2:
				try_harvest(mouseloc,harvestsize)
		if event.is_action_pressed("RightClick"):
			select(null)
		if event.is_action_pressed("EndTurn"):
			if !can_harvest:
				end_turn()
		if event.is_action_pressed("Plant"):
			highlight_plant()
		if event.is_action_pressed("Harvest"):
			select(null)
			if can_harvest: 
				prev_cursor_loc = null
				mode=2
		if event.is_action_pressed("Wrath"):
			if can_harvest:
				wrath = 1
				can_harvest = false
				select(null)

func highlight_plant():
	select(null)
	if can_harvest: 
		prev_cursor_loc = null
		mode=1
		for x in range(size):
			for y in range(size):
				var show_cell = false
				var units = get_units(Vector2i(x,y))
				show_cell=show_cell||check_friendly(Vector2i(x+1,y))
				show_cell=show_cell||check_friendly(Vector2i(x,y+1))
				show_cell=show_cell||check_friendly(Vector2i(x-1,y))
				show_cell=show_cell||check_friendly(Vector2i(x,y-1))
				show_cell=show_cell||check_friendly(Vector2i(x+1,y+1))
				show_cell=show_cell||check_friendly(Vector2i(x+1,y-1))
				show_cell=show_cell||check_friendly(Vector2i(x-1,y+1))
				show_cell=show_cell||check_friendly(Vector2i(x-1,y-1))
				show_cell=show_cell&&(units.is_empty()||((units[0].passable || !has_neutral(Vector2i(x,y),2))&&!has_neutral(Vector2i(x,y),0)&&!has_neutral(Vector2i(x,y),1)))
				if show_cell: 
					set_cell(1,Vector2i(x,y),0,Vector2i(0,1))
					
func check_friendly(loc:Vector2i):
	var units = get_units(loc)
	return !units.is_empty()&&units[0].type==0
func end_turn():
	emit_signal("next_turn")
	select(null)
	wrath = 0
	#process dying units
	for unit in get_children():
		if unit.is_in_group("non_unit"): continue
		if unit.curhp<=0:
			unit.die()
		if unit.type==1:
			unit.passable = false
	#process enemy actions
	for unit in get_children():
		if unit.is_in_group("non_unit"): continue
		if unit.type==1:
			processqueue.append(unit)
	process_next()

func process_next():
	if !processqueue.is_empty():
		var tmp = processqueue.pop_front()
		tmp.autopilot()
	else:
		#enemy spawn
		spawn_enemies()
		#reset for new turn
		for unit in get_children():
			if unit.is_in_group("non_unit"): continue
			if unit.type==0:
				unit.state = 0
		can_harvest = true
		turn+=1

func spawn_enemies():
	pass

func summon(loc:Vector2i, unit:int):
	var inst = summon_units[unit].instantiate()
	inst.position = map_to_local(loc)
	inst.state = 2
	add_child(inst)

func select(target : Node2D):
	clear_layer(1)
	clear_layer(2)
	if target == null:
		mode=0
		node_selected.visible=false
		selected = null
	else:
		node_selected.position=map_to_local(local_to_map(target.position))
		node_selected.visible = true
		selected = target
		#add show desc here
		if target.type == 0:
			if target.state == 0:
				var places = target.get_moves()
				for i in places:
					set_cell(1,i,0,Vector2i(0,1))
			elif target.state == 1:
				var places = target.get_attacks()
				for i in places:
					set_cell(1,i,0,Vector2i(0,0))
	emit_signal("change_mode")

func attack_tile(loc : Vector2i, from : Vector2i, dmg : int):
	var targets = get_units(loc)
	var dieded = false
	for i in targets:
		dieded = dieded || i.takedamage(dmg, from)
		if !i.passable: break
	return dieded

func has_neutral(loc:Vector2i, subtype:int):
	var units = get_units(loc)
	for i in units:
		if i.type==2:
			if i.subtype == subtype:
				return true
	return false

func try_fertilize(loc : Vector2i):
	var units = get_units(loc)
	if has_neutral(loc,0) && has_neutral(loc,2):
		for i in units:
			if i.type==2 && i.subtype!=1:
				i.die()
		summon(loc, 7)

func get_harvest(loc:Vector2i, size:int):
	var ans = [loc]
	if size != 1 && size != 3 && is_in_map(loc+Vector2i(0,1)): ans.append(loc+Vector2i(0,1))
	if size>2 && is_in_map(loc+Vector2i(1,0)): ans.append(loc+Vector2i(1,0))
	if size==3||size==5 && is_in_map(loc+Vector2i(-1,0)): ans.append(loc+Vector2i(-1,0))
	if size == 4 && is_in_map(loc+Vector2i(1,1)): ans.append(loc+Vector2i(1,1))
	if size == 5 && is_in_map(loc+Vector2i(0,-1)): ans.append(loc+Vector2i(0,-1))
	return ans

func try_harvest(loc:Vector2i, size:int):
	var targets = get_harvest(loc,size)
	var canharvest = true
	for i in targets:
		canharvest = canharvest && has_neutral(i,1)
	if canharvest:
		for i in targets:
			get_units(i)[0].queue_free()
		summon(loc,size)
		mode = 0
		can_harvest = false
		select(null)
func get_units(loc : Vector2i):
	var ans = []
	for unit in get_children():
		if unit.is_in_group("non_unit"): continue
		if local_to_map(unit.position)==loc:
			if unit.passable:
				ans.append(unit)
			else:
				ans.push_front(unit)
	return ans

func biggest_dimension(vec : Vector2i): #this is used to determine the push direction based on the position of the pusher and the pushee
	return Vector2i(sign(vec.x)*int(abs(vec.x)>=abs(vec.y)),sign(vec.y)*int(abs(vec.y)>=abs(vec.x)))
func is_in_map(loc:Vector2i):
	return loc.x>=0 && loc.x<size&&loc.y>=0 &&loc.y<size
