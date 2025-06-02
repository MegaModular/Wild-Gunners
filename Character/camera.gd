extends Camera2D

var following : Object = null

@onready var player = $"../Character"

func _process(_delta: float) -> void:
	if following != null:
		position = lerp(position, following.position, 0.1) 
		return
	position = lerp(position, player.position, 0.1)
