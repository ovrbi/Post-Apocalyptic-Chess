extends Label

var tilemap
var isready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = $/root/MainScene/Board
	print(tilemap)
	isready = true
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _update():
	if isready:
		text = "TURN #" + str(tilemap.turn)


func _on_board_next_turn():
	_update()
