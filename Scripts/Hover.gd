extends Label

var board

var hovering = null
var button = "none" # hovers = none | endturn | plant | harvest | wrath | one | two | three | four | five
var mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	board = $/root/MainScene/Board


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_text():
	if button == "one": # summoning units
		text = "Summon a Sproutling."
	elif button == "two":
		text = "Summon a Thistleslinger."
	elif button == "three":
		text = "Summon a Vineghoul."
	elif button == "four":
		text = "Summon a Lavender-Mender."
	elif button == "five":
		text = "Summon a Monstrous Treant."
	if mode == 2: #harvesting
		text = "Choose the shape of the harvest:"
	elif button != "none": # hovering button
		match button:
			"endturn":
				text = "End the current turn."
			"plant":
				text = "Plant a new sprout.\nSprouts need to be fertilized by corses to grow."
			"wrath":
				text = "Evoke natures wrath, making all friendly\nunits do one extra damage this turn."
	elif mode == 1: # planting
		text = "Choose where to seed the new sprout."
	elif button == "harvest":
		text = "Harvest fully grown plants to\ncreate new units."
	elif hovering != null: # hovering over a unit
		pass
	else: # nothing is being hovered
		text = " "
	


func _on_board_change_hover():
	pass # Replace with function body.


func _on_board_change_mode():
	board = $/root/MainScene/Board
	mode = board.mode
	update_text()
	print(mode)

# next turn button
func _on_next_turn_mouse_entered():
	button = "endturn"
	update_text()
func _on_next_turn_mouse_exited():
	if button == "endturn": button = "none"
	update_text()
func _on_next_turn_hidden():
	if button == "endturn": button = "none"
	update_text()

# plant button
func _on_plant_mouse_entered():
	button = "plant"
	update_text()
func _on_plant_mouse_exited():
	if button == "plant": button = "none"
	update_text()
func _on_plant_hidden():
	if button == "plant": button = "none"
	update_text()

# harvest button
func _on_harvest_mouse_entered():
	button = "harvest"
	update_text()
func _on_harvest_mouse_exited():
	if button == "harvest": button = "none"
	update_text()
func _on_harvest_hidden():
	if button == "harvest": button = "none"
	update_text()

# wrath button
func _on_wrath_mouse_entered():
	button = "wrath"
	update_text()
func _on_wrath_mouse_exited():
	if button == "wrath": button = "none"
	update_text()
func _on_wrath_hidden():
	if button == "wrath": button = "none"
	update_text()

# one button
func _on_one_mouse_entered():
	button = "one"
	update_text()
func _on_one_mouse_exited():
	if button == "one": button = "none"
	update_text()
func _on_one_hidden():
	if button == "one": button = "none"
	update_text()

# two button
func _on_two_mouse_entered():
	button = "two"
	update_text()
func _on_two_mouse_exited():
	if button == "two": button = "none"
	update_text()
func _on_two_hidden():
	if button == "two": button = "none"
	update_text()

# three button
func _on_three_mouse_entered():
	button = "three"
	update_text()
func _on_three_mouse_exited():
	if button == "three": button = "none"
	update_text()
func _on_three_hidden():
	if button == "three": button = "none"
	update_text()


func _on_four_mouse_entered():
	button = "four"
	update_text()
func _on_four_mouse_exited():
	if button == "four": button = "none"
	update_text()
func _on_four_hidden():
	if button == "four": button = "none"
	update_text()


func _on_five_mouse_entered():
	button = "five"
	update_text()
func _on_five_mouse_exited():
	if button == "five": button = "none"
	update_text()
func _on_five_hidden():
	if button == "five": button = "none"
	update_text()
