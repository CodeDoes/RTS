extends Area2D

signal recieve_damage


var team 
var _health = 5
var speed = 30.0
var _path 
var path_update_time = 0.0
var path_update_frequency = 0.3
var attack_dist = 8*1
var attack_start_dist=16*4
#onready var states = {
#	idle=["idle_1","idle_2"],
#	move=["run_cycle"],
#	attack=["slash_once"]
#}
onready var render = get_node('render')
#
#func set_animation(name,idx=0,step=0):
#	if render.is_connected("finished",self,"set_animation"):
#		render.disconnect("finished",self,"set_animation")
#	idx=(idx+step)%animations[name].size()
#	animation=animations[name][idx]
#	render.play(animation)
#	render.connect("finished",self,"set_animation",[name,idx,1])
	
func get_closest_enemy():
	var enemy 
	for other in get_parent().get_children():
		var dist = get_global_pos().distance_to(other.get_global_pos())
		if (other extends load('res://soldier/soldier.gd')
		and other!=self 
		and other.team!=team 
		and (enemy==null or dist<enemy[1])):
			enemy=[other,dist]
	if enemy!=null: 
		return enemy[0]
func _ready():
	team = int(rand_range(0,2))
	if team ==0:
		render.set_modulate(Color(1.0,0.0,0.0,1.0))
	if team ==1:
		render.set_modulate(Color(0.0,1.0,0.0,1.0))
	print (team)
	idle()
	set_process(true)
	connect("recieve_damage",self,"_on_recieve_damage")
func _on_recieve_damage(damage):
	_health-=damage
	if _health<=0:
		queue_free()
func _path_update():
	_path = Array(get_parent().get_simple_path(get_global_pos(),_path[-1]))
	
func move_to(target):
	if target!=null:
		_path=[target]
		_path_update()
	else:
		_path=null
#idle --> (attack_move)
#attack_move(move) --> (attack)
#attack --> (attack,idle,move)
func idle():
	render.set_animation("idle")
	render.set_frame(randi()%render.get_sprite_frames().get_frame_count('idle'))
	
var _enemy
func _process(delta):
	#print(render.get_animation(),_path)
	if render.get_animation()!="attack":
		if (_enemy!=null or _path==null):
			#if already has enemy or not moving
			_enemy = get_closest_enemy()
			if (_enemy!=null 
			and get_global_pos().distance_to(_enemy.get_global_pos())<attack_start_dist):
				#if enemy within chase distance
				if get_global_pos().distance_to(_enemy.get_global_pos())<attack_dist:
					#if enemy within attack distance
					move_to(null)
					var enemy = weakref(_enemy)
					render.play("attack")# start attack animation
					yield (render,"finished")#wait until animation complete
					if enemy.get_ref()!=null and get_global_pos().distance_to(_enemy.get_global_pos())<attack_dist:
						#repeat attack if enemy still alve and close enough
						_enemy.emit_signal("recieve_damage",1)
					idle()
					if _path!=null:
						#if move order has been given while attacking, forget enemy
						_enemy=null
						#print('forget_enemy')
				else:
					# otherwise chase enemy
					if _path==null or _enemy.get_global_pos()!=_path[-1]:
						# if path null or enemy moved 
						move_to(_enemy.get_global_pos())
		if _path!=null:
			if get_global_pos()==_path[-1]:
				#already at path end
				idle()
				move_to(null)
			else:
				#print ("move")
				#path clipping
				while _path.size()>1 and get_global_pos().distance_to(_path[0])<speed*delta:
					_path.pop_front()
				var target= _path[0]
				#movement
				var diff=(target-get_global_pos())
				diff=diff.normalized()*min(diff.length(),speed*delta)
				set_global_pos(get_global_pos()+diff)
				if diff.length()>0:
					render.play('move')
					if diff.x!=0:
						render.set_flip_h(diff.x<0)
				
				#path_updating
				path_update_time+=delta
				if path_update_time>path_update_frequency:
					path_update_time=max(path_update_time-path_update_frequency,0)
					_path_update()
	
	