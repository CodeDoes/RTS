extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		set_global_pos(get_global_mouse_pos())
