extends Label

var tilemap
var isready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = $/root/MainScene/Board
	isready = true
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update():
	if !isready: tilemap = $/root/MainScene/Board
	text = "SCORE: " + str(tilemap.points)

func _on_board_change_mode():
	_update()
