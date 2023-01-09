extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label2.text = "Final Score: "+str($/root/MainScene/Board.points)
	if $/root/MainScene/Board.points>=30:
		$Label3.visible = true
	$/root/MainScene/Music.stop()
	#$/root/MainScene.queue_free()





func _on_gui_input(event):
	if event.is_action_pressed("LeftClick") || event.is_action_pressed("EndTurn"):
#		var pref = preload("res://Scenes/main_scene.tscn").instantiate()
#		print("----")
#		get_node("/root").add_child(pref)
#		print(get_tree().to_string())
		get_tree().reload_current_scene()
		queue_free()
