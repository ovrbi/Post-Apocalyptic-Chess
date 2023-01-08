extends TileMap

const size = 6
var input_lock = false
var selected : Node2D
var processqueue = []
@export var node_selector : Node2D
@export var node_selected : Node2D
var turn = 0
var can_harvest = true

# Called when the node enters the scene tree for the first time.
func _ready():
	selected = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouseloc = local_to_map(get_viewport().get_mouse_position()-position)
	if mouseloc.x>-2&&mouseloc.y>-2&&mouseloc.x<=size &&mouseloc.y<=size:
		node_selector.visible=true
		node_selector.position=map_to_local(mouseloc)
	else:
		node_selector.visible=false

func _unhandled_input(event : InputEvent):
	if !input_lock:
		if event.is_action_pressed("LeftClick"):
			var mouseloc = local_to_map(get_viewport().get_mouse_position()-position)
			var mouse_t = get_units(mouseloc)
			if get_cell_source_id(0,mouseloc)==-1||(selected!=null&&mouse_t.has(selected)):
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
					pass
		if event.is_action_pressed("RightClick"):
			select(null)
		if event.is_action_pressed("EndTurn"):
			end_turn()

func end_turn():
	select(null)
	#process dying units
	
	#process enemy actions
	for unit in get_children():
		if unit.is_in_group("non_unit"): continue
		if unit.type==1:
			processqueue.append(unit)
	process_next()

func process_next():
	if !processqueue.is_empty():
		pass
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

func select(target : Node2D):
	if target == null:
		node_selected.visible=false
		clear_layer(0)
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
					set_cell(0,i,0,Vector2i(0,0))
#					print(i)
			elif target.state == 1:
				pass

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

func is_in_map(loc:Vector2i):
	return loc.x>=0 && loc.x<size&&loc.y>=0 &&loc.y<size
