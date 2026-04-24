extends Area2D
signal hit

@export var attack_scene: PackedScene  # 僚机场景
var attack:Node =null   # 当前唯一的僚机
var invincible_time: float = 0.0
#@export var invincible_duration: float = 1.0
@export var max_health: int = 50
@export var max_energy: int = 100
@export var base_speed: float = 310.0
@export var base_ATK:int = 4
var weapon_spin_bonus: float = 0.0
var screen_size
var health: int
var energy: int
var speed:float
var ATK:int
# ---------------
# 四种状态
# ---------------
var is_burning: bool = false
var is_cold: bool = false
var is_electric: bool = false
var is_wet: bool = false

#var atk_ready: bool = true
#var def_ready: bool = true
#var hp_ready: bool = true
var is_inDUN:bool = false
var is_rush:bool=false
var is_charging: bool = false
func _ready() -> void:
	screen_size= get_viewport_rect().size
	health = max_health
	energy = 0
	speed = base_speed
	ATK = base_ATK
	$AnimatedSprite2D.animation="down"
	hide()
	pass # Replace with function body.

func _process(delta: float) -> void:
	_handle_charge_input()
	handle_states(delta)
	_update_state_effect()
	if Input.is_action_just_pressed("skill_atk"):
		try_cast_atk()
	if Input.is_action_just_pressed("skill_def"):
		try_cast_def()
	if Input.is_action_just_pressed("skill_hp"):
		try_cast_hp()
	if speed==0:
		return
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		if $AnimatedSprite2D.animation != "hit":
			$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if $AnimatedSprite2D.animation == "hit":
		return
	if velocity.x != 0 :
		if velocity.y==0:
			$AnimatedSprite2D.animation = "side"
		elif velocity.y>0:
			$AnimatedSprite2D.animation="down"
		elif velocity.y<0:
			$AnimatedSprite2D.animation="up"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		if velocity.y>=0:
			$AnimatedSprite2D.animation="down"
		else:
			$AnimatedSprite2D.animation="up"	
	pass

#处理状态（无敌时间，冻结）
func handle_states(delta):
	#无敌时间
	if invincible_time > 0.0:
		invincible_time = max(0.0, invincible_time - delta)
	# 速度
	var target_speed := base_speed

	if is_rush:
		target_speed = base_speed + 150
	elif is_cold and is_wet:
		target_speed = 0
	elif is_cold:
		target_speed = base_speed * 0.65
	if is_charging:
		target_speed *= 0.3
	speed = target_speed
	if speed==0:
		var sprite := $AnimatedSprite2D
		if sprite.sprite_frames.has_animation(&"frozen"):
				sprite.animation = &"frozen"
		sprite.play()
#赋予角色状态
func apply_burn():
	# 优先级：寒冷 → 潮湿 → 感电 → 正常燃烧
	if  is_inDUN:
		return
		
	if is_cold:
		# 抵消寒冷 → 给潮湿3秒
		is_cold = false
		change_energy(6)
		apply_wet(3.0)
	elif is_wet:
		return
	elif is_electric:
		is_electric = false
		boom()
		take_demage(14,true)
	else:
		# 正常燃烧
		is_burning = true
		$FireDurationTimer.start(7.0)
		$FireTickTimer.start()
func apply_cold():
	if is_inDUN:
		return
	if is_burning:
		is_burning = false
		change_energy(6)
		apply_wet(3.0)
		return
	# 寒冷可以和潮湿、感电共存
	is_cold = true
	$ColdDurationTimer.start(4.0)
func apply_electric():
	if  is_inDUN:
		return
	if is_burning:
		is_burning = false
		boom()
		take_demage(13,true)
		return
	# 感电可与寒冷、潮湿共存
	is_electric = true
	$LightDurationTimer.start(5.0)
	$LightTickTimer.start()
func apply_wet(duration: float = 5.0):
	if is_burning:
		is_burning = false
	is_wet = true
	$WetDurationTimer.start(duration)
	$WetTickTimer.start()

#角色能量更新	
func change_energy(amount:int):
	if amount>=0:
		energy=min(energy+amount,max_energy)
	else:
		energy=max(energy+amount,0)
	var main = get_tree().get_root().get_node("Main")
	if main != null and is_instance_valid(main):
		if(amount>=0):
			main.spawn_floating_text(
				"+" + str(amount),
				Color(0.0, 0.561, 1.0, 1.0), # 蓝青色
				global_position + Vector2(0, -50)
			)

#角色受伤
func take_demage(amount: int, ignore_invincible: bool = false) -> void:
	if is_inDUN:
		return
	if not ignore_invincible and invincible_time > 0.0:
		return
	health -= amount
	var main = get_tree().get_root().get_node("Main")
	if main != null and is_instance_valid(main):
		main.spawn_floating_text("-" + str(amount), Color(0.955, 0.302, 0.0, 1.0), global_position + Vector2(0, -30))
	if health > 0:
		play_hit_animation()
	if not ignore_invincible:
		invincible_time = 1.0
	if health <= 0:
		die()
func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	var main = get_tree().get_root().get_node("Main")
	if main != null:
		main.spawn_floating_text("+" + str(amount), Color(0.3, 1, 0.3), global_position + Vector2(0, -40))
	
#死亡
func die():
	if attack != null and is_instance_valid(attack):
		attack.queue_free()
	attack = null
	hide() 
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
#撞击怪物
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		if body.has_method("take_demage"):
			body.take_demage(1)
			pass
		# 从 mob 读伤害和类型
		body.apply_effect_to_player(self)

	pass # Replace with function body.
#拾取物品，获得武器
func on_item_picked() -> void:
	if attack == null or not is_instance_valid(attack):
		if attack_scene == null:
			return

		attack = attack_scene.instantiate()
		attack.player = self
		attack.main = get_tree().get_root().get_node("Main")
		attack.angular_speed += weapon_spin_bonus
		# 用 call_deferred 推迟 add_child 到本帧物理处理之后
		get_parent().call_deferred("add_child", attack)

	call_deferred("_restart_attack_timer")

#武器强化
func add_weapon_spin_speed(amount: float) -> void:
	weapon_spin_bonus += amount
	if attack != null and is_instance_valid(attack):
		attack.angular_speed += amount
#释放技能
func try_cast_atk() -> void:
	if energy<35:
		return
	change_energy(-35)
	take_atk()
	# 范围伤害：按距离找 mobs
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not is_instance_valid(mob):
			continue
		if mob.global_position.distance_to(global_position) <= 400:
			if mob.has_method("take_demage"):
				mob.take_demage(999)
			else:
				mob.queue_free()
func try_cast_def() -> void:
	if energy<20:
		return
	change_energy(-20)
	#def_ready = false
	is_inDUN = true
	$DefDurationTimer.start(2.5)
	#$WCooldownTimer.start(w_cd)
func try_cast_hp() -> void:
	if energy<40:
		return
	change_energy(-40)
	is_rush=true
	$HPDurationTimer.start(5)
	$AnimatedSprite2D/Speed.visible=true
	$AnimatedSprite2D/Speed.play()
	heal(10)
	#$ECooldownTimer.start(e_cd)
func _handle_charge_input() -> void:
	if Input.is_action_pressed("skill_charge"):
		start_charge()
	else:
		stop_charge()
func start_charge() -> void:
	if is_charging:
		return
	if energy >= max_energy:
		return
	is_charging = true
	$ChargeTickTimer.start()
	$AnimatedSprite2D/Charge.visible = true
	$AnimatedSprite2D/Charge.play()
func stop_charge() -> void:
	if not is_charging:
		return
	is_charging = false
	$ChargeTickTimer.stop()
	$AnimatedSprite2D/Charge.visible = false
	$AnimatedSprite2D/Charge.stop()		


func _restart_attack_timer() -> void:
	$Timer.stop()
	$Timer.start()
	pass
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


#清除武器
func _on_timer_timeout() -> void:
	if attack != null and is_instance_valid(attack):
		attack.queue_free()
	attack = null
	pass # Replace with function body.

#状态时间
func _on_fire_duration_timer_timeout() -> void:
	is_burning=false
	$FireTickTimer.stop()
	pass # Replace with function body.
func _on_fire_tick_timer_timeout() -> void:
	if is_burning:
		take_demage(1,true)
	pass # Replace with function body.
func _on_cold_duration_timer_timeout() -> void:
	is_cold=false
	pass # Replace with function body.
func _on_light_duration_timer_timeout() -> void:
	is_electric=false
	$LightTickTimer.stop()
	pass # Replace with function body.
func _on_light_tick_timer_timeout() -> void:
	if is_electric:
		var drain := 12 if is_cold else 8
		change_energy(-drain)
		var main = get_tree().get_root().get_node("Main")
		if main != null and is_instance_valid(main):
			main.spawn_floating_text(
				"-" + str(drain),
				Color(0.42, 0.035, 1.0, 1.0), 
				global_position + Vector2(0, -50)
			)
	pass # Replace with function body.
func _on_wet_duration_timer_timeout() -> void:
	is_wet = false
	$WetTickTimer.stop()
	pass # Replace with function body.
func _on_wet_tick_timer_timeout() -> void:
	if is_wet:
		change_energy(4)
	pass # Replace with function body.
#受击动画
func play_hit_animation() -> void:
	var sprite := $AnimatedSprite2D
	if sprite.sprite_frames.has_animation(&"hit"):
		sprite.animation = &"hit"
		sprite.play()
#受击动画结束
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		$AnimatedSprite2D.animation = "down"
		$AnimatedSprite2D.play()
	pass # Replace with function body.
#更新特效
func _update_state_effect() -> void:
	var effect := $AnimatedSprite2D/VFX 
	if not effect.sprite_frames:
		return
	elif is_inDUN:
		effect.visible = true
		effect.animation = &"DUN"
		effect.play()
	elif is_burning:
		effect.visible = true
		effect.animation = &"fire"
		effect.play()
	elif is_cold:
		effect.visible = true
		effect.animation = &"cold"
		effect.play()
	elif is_electric:
		effect.visible = true
		effect.animation = &"light"
		effect.play()
	elif is_wet:
		effect.visible = true
		effect.animation = &"wet"
		effect.play()

	else:
		effect.visible = false
		effect.stop()
func boom():
	$AnimatedSprite2D/Boom.visible=true
	$AnimatedSprite2D/Boom.play()
func _on_boom_animation_finished() -> void:
	$AnimatedSprite2D/Boom.visible=false
	pass # Replace with function body.
func take_atk():
	$AnimatedSprite2D/ATK.visible=true
	$AnimatedSprite2D/ATK.play()
func _on_atk_animation_finished() -> void:
	$AnimatedSprite2D/ATK.visible=false
	pass # Replace with function body.

func _on_def_duration_timer_timeout() -> void:
	is_inDUN=false
	pass # Replace with function body.
func _on_hp_duration_timer_timeout() -> void:
	is_rush=false
	speed=base_speed
	$AnimatedSprite2D/Speed.visible=false
	pass # Replace with function body.


func _on_charge_tick_timer_timeout() -> void:
	if not is_charging:
		return
	var r := randf()
	if r < 0.7:
		r=1
	elif r < 0.9:
		r=2
	else:
		r=5
	change_energy(r)
	pass # Replace with function body.
