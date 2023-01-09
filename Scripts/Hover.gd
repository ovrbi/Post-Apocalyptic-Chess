extends Label

var basetext = " "
var hovering = null
var button = "none" # hovers = none | endturn | plant | harvest | wrath | one | two | three | four | five
var mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_text():
	if button != "none": # hovering button
		match button:
			"endturn":
				text = "End the current turn."
	elif mode != 0: # planting or harvesting
		pass
	elif hovering != null: # hovering over a unit
		pass
	else: # nothing is being hovered
		text = " "
	


func _on_board_change_hover():
	pass # Replace with function body.


func _on_board_change_mode():
	pass # Replace with function body.


func _on_next_turn_mouse_entered():
	button = "endturn"
	update_text()

func _on_next_turn_mouse_exited():
	if button == "endturn": button = "none"
	update_text()
