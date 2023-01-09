extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label2.text = "Final SCORE: "+str($/root/MainScene/Board.points)
	$/root/MainScene.free()
#	get_node("/root").remove_child()




func _on_gui_input(event):
	if event.is_action_pressed("LeftClick") || event.is_action_pressed("EndTurn"):
		get_node("/root").add_child(preload("res://Scenes/main_scene.tscn").instantiate())
		queue_free()
