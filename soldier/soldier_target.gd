extends DampedSpringJoint2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#set_node_a('..')
	get_parent().connect("move_to",self,"_set_move_to")
func _set_move_to(point):
	set_global_pos(point)
	