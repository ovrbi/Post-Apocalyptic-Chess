extends TileMap

signal next_turn
signal change_hover
signal change_mode

const size = 8
var input_lock = 0
var mode = 0 #0:normal 1:plant 2:harvest
var harvestsize = 1
var selected : Node2D
var processqueue = []
@export var node_selector : Node2D
@export var node_selected : Node2D
var turn = 0
var points = 0
var can_harvest = false
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
var costs = [5,9,13,17,21,25]
var harvest_cheats = true

var wrath = 0
var ms_boost = 0
var extra_attack = 0
var frame_time = 0.0
var prev_frame = 0

var tb_nextturn
var tb_plant
var tb_harvest
var tb_wrath
var tb_one
var tb_two
var tb_three
var tb_four
var tb_five

# Called when the node enters the scene tree for the first time.
func _ready():
	#import buttons
	tb_nextturn = $/root/MainScene/Control/NextTurn
	tb_plant = $/root/MainScene/Control/Plant
	tb_harvest = $/root/MainScene/Control/Harvest
	tb_wrath = $/root/MainScene/Control/Wrath
	tb_one = $/root/MainScene/Control/One
	tb_two = $/root/MainScene/Control/Two
	tb_three = $/root/MainScene/Control/Three
	tb_four = $/root/MainScene/Control/Four
	tb_five = $/root/MainScene/Control/Five
	
	selected = null
	prev_cursor_loc = null
	var rand = randi() % 4
	if rand!=0:
		summon(Vector2i(3,3),0)
	if rand!=1:
		summon(Vector2i(3,4),0)
	if rand!=2:
		summon(Vector2i(4,3),0)
	if rand!=3:
		summon(Vector2i(4,4),0)
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
	
	
	frame_time += delta*2
	if frame_time >= 2:
		frame_time = frame_time-2
	if int(frame_time)!=prev_frame:
		prev_frame = int(frame_time)
		var children = get_children()
		for child in children:
			if child.is_in_group("non_unit"): continue
			child.frame = prev_frame

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
			elif mode == 1: #planting
				if get_cell_source_id(1,mouseloc)!=-1:
					tb_nextturn.visible = true
					tb_plant.visible = false
					tb_harvest.visible = false
					tb_wrath.visible = false
					summon(mouseloc,6)
					mode = 0
					can_harvest = false
					select(null)
			elif mode == 2:
				try_harvest(mouseloc,harvestsize)
		if event.is_action_pressed("RightClick"):
			select(null)
		if event.is_action_pressed("EndTurn"):
			button_endturn()
		if event.is_action_pressed("Plant"):
			button_plant()
		if event.is_action_pressed("Harvest"):
			button_harvest()
		if event.is_action_pressed("Wrath"):
			button_wrath()

func button_endturn():
	if !can_harvest:
		end_turn()

func button_plant():
	if tb_plant.button_pressed == true:
		highlight_plant()
		tb_plant.button_pressed = true
	else:
		select(null)

func button_harvest():
	if tb_harvest.button_pressed == true:
		select(null)
		if can_harvest: 
			tb_one.visible = true
			tb_two.visible = true
			tb_three.visible = true
			tb_four.visible = true
			tb_five.visible = true
			prev_cursor_loc = null
			mode=2
			tb_harvest.button_pressed = true
	else: select(null)

func button_wrath():
	if can_harvest:
		tb_nextturn.visible = true
		tb_plant.visible = false
		tb_harvest.visible = false
		tb_wrath.visible = false
		wrath = 1
		can_harvest = false
		select(null)


func highlight_plant():
	select(null)
	if can_harvest: 
		prev_cursor_loc = null
		mode=1
		select(null)
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
				show_cell=show_cell&&(units.is_empty()||(units[0].passable && !has_neutral(Vector2i(x,y),0)&&!has_neutral(Vector2i(x,y),1)))
				if show_cell: 
					set_cell(1,Vector2i(x,y),0,Vector2i(0,1))
					
func check_friendly(loc:Vector2i):
	var units = get_units(loc)
	return !units.is_empty()&&units[0].type==0
func end_turn():
	if turn!=0:
		#tb_nextturn.disabled = true
		tb_nextturn.visible = false
		tb_plant.visible = true
		tb_harvest.visible = true
		tb_wrath.visible = true
	turn+=1
	input_lock+=1
	emit_signal("next_turn")
	select(null)
	wrath = 0
	#process dying units
	for unit in get_children():
		if unit.is_in_group("non_unit"): continue
		if unit.curhp<=0:
			unit.die()
	#process enemy actions
	for unit in get_children():
		if unit.is_in_group("non_unit"): continue
		if unit.type==1:
			for i in range(extra_attack+1):
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
				unit.modulate.a=1
		if turn>1:
			can_harvest = true
		input_lock-=1

func spawn_enemies():
	var pts = turn+4
	var sums = [0,0,0,0,0,0]
	if pts>costs[4]*(size+size-2):
		sums = [0,0,0,0,12,2]
		for i in range(2):
			edge_summon(14)
		for i in range(12):
			edge_summon(13)
	else:
		for i in range(6):
			var amount = randi_range(int(pts/costs[5-i]/4),int(pts/costs[5-i]))
			if i == 0 || i==2:
				if pts < int(costs[5-i]*1.5): amount=0
				else: amount = min(1,amount)
			sums[5-i]=amount
			for j in range(amount):
				edge_summon(14-i)
			pts -= amount*costs[5-i]
	if sums == [0,0,0,0,0,0]: edge_summon(9)

func edge_summon(unit:int):
	var locs = []
	var backuplocs = []
	for i in range(size):
		if get_units(Vector2i(0,i)).is_empty()||!get_units(Vector2i(0,i))[0].passable: locs.append(Vector2i(0,i))
		if get_units(Vector2i(size-1,i)).is_empty()||!get_units(Vector2i(size-1,i))[0].passable: locs.append(Vector2i(size-1,i))
		backuplocs.append(Vector2i(0,i))
		backuplocs.append(Vector2i(size-1,i))
	for i in range(1,size-1):
		if get_units(Vector2i(i,0)).is_empty()||!get_units(Vector2i(i,0))[0].passable: locs.append(Vector2i(i,0))
		if get_units(Vector2i(i,size-1)).is_empty()||!get_units(Vector2i(i,size-1))[0].passable: locs.append(Vector2i(i,size-1))
		backuplocs.append(Vector2i(i,0))
		backuplocs.append(Vector2i(i,size-1))
	if !locs.is_empty(): summon(locs[randi_range(0,locs.size()-1)],unit)
	else:
		var loc = backuplocs[randi_range(0,backuplocs.size()-1)]
		var units = get_units(loc)
		if !units[0].passable:
			units[0].queue_free()
		summon(loc, unit)

func has_enemy(loc:Vector2i):
	var ans = false
	var units = get_units(loc)
	for i in units:
		if i.type==1: ans=true
	return ans

func summon(loc:Vector2i, unit:int):
	var inst = summon_units[unit].instantiate()
	inst.position = map_to_local(loc)
	inst.state = 2
	add_child(inst)

func select(target : Node2D):
	clear_layer(1)
	clear_layer(2)
	if target == null:
		tb_one.visible = false
		tb_two.visible = false
		tb_three.visible = false
		tb_four.visible = false
		tb_five.visible = false
		tb_harvest.button_pressed = false
		tb_plant.button_pressed = false
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

func get_harvest(loc:Vector2i, hsize:int):
	var ans = [loc]
	if hsize != 1 && hsize != 3 && is_in_map(loc+Vector2i(0,1)): ans.append(loc+Vector2i(0,1))
	if hsize>2 && is_in_map(loc+Vector2i(1,0)): ans.append(loc+Vector2i(1,0))
	if hsize==3||hsize==5 && is_in_map(loc+Vector2i(-1,0)): ans.append(loc+Vector2i(-1,0))
	if hsize == 4 && is_in_map(loc+Vector2i(1,1)): ans.append(loc+Vector2i(1,1))
	if hsize == 5 && is_in_map(loc+Vector2i(0,-1)): ans.append(loc+Vector2i(0,-1))
	return ans

func try_harvest(loc:Vector2i, hsize:int):
	var targets = get_harvest(loc,hsize)
	var canharvest = harvest_cheats || targets.size()==hsize
	for i in targets:
		canharvest = canharvest && has_neutral(i,1) 
	if canharvest:
		tb_nextturn.visible = true
		tb_plant.visible = false
		tb_harvest.visible = false
		tb_wrath.visible = false
		for i in targets:
			get_units(i)[0].queue_free()
		points+=hsize
		if size==5: points+=5
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

# sync up buttons with game logic
func _on_next_turn_pressed():
	button_endturn()
func _on_wrath_pressed():
	button_wrath()
func _on_plant_pressed():
	button_plant()
func _on_harvest_pressed():
	button_harvest()
func clear_harvest_buttons():
	tb_one.button_pressed = false
	tb_two.button_pressed = false
	tb_three.button_pressed = false
	tb_four.button_pressed = false
	tb_five.button_pressed = false
func _on_one_pressed():
	clear_harvest_buttons()
	tb_one.button_pressed = true
	harvestsize = 1
func _on_two_pressed():
	clear_harvest_buttons()
	tb_two.button_pressed = true
	harvestsize = 2
func _on_three_pressed():
	clear_harvest_buttons()
	tb_three.button_pressed = true
	harvestsize = 3
func _on_four_pressed():
	clear_harvest_buttons()
	tb_four.button_pressed = true
	harvestsize = 4
func _on_five_pressed():
	clear_harvest_buttons()
	tb_five.button_pressed = true
	harvestsize = 5
