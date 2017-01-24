extends Navigation2D

var soldier_prefab = preload('res://soldier/soldier.tscn')
var _summon_time=0.0
var summon_frequency=3.0
func _ready():
	for i in range(10):
		summon()
	set_process(true)
	set_process_input(true)
func _process(delta):
	_summon_time+=delta
	if _summon_time>=summon_frequency:
		_summon_time=max(0.0,_summon_time-summon_frequency)
		summon()
func summon():
	var soldier = soldier_prefab.instance()
	add_child(soldier)
	soldier.set_global_pos(Vector2(randf(),randf())*get_viewport().get_rect().size)
func _input(event):
	if (event.type==InputEvent.MOUSE_BUTTON 
	and event.button_index==BUTTON_LEFT 
	and event.pressed==false):
		var soldiers =[]
		for c in get_children():
			if (c extends load('soldier/soldier.gd') 
			and c.team==0):
				soldiers.append(c)
		send_soldier_to(soldiers,event.global_pos)
		
func send_soldier_to(soldiers,point):
	var dim = int(ceil(soldiers.size()/2))
	var b = 10.0
	for y in range(dim):
		for x in range(dim):
			var slot = point+Vector2(x*b,y*b)-Vector2(floor(dim/2)*b,floor(dim/2)*b)
			if soldiers.size()>0:
				soldiers[0].move_to(slot)
				if soldiers[0].render.get_animation()!='attack':
					soldiers[0]._enemy=null
				soldiers.pop_front()
	