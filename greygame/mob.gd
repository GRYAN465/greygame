extends RigidBody2D

enum MobType{
	Fire,
	Ice,
	Light
}
@export var animationType: StringName = &""
@export var mob_type:MobType=MobType.Fire
@export var max_health:int=1
@export var max_demage:int=1
@export var max_speed:float=150.0
var cu_health:int
var cu_demage:int
var cu_speed:float
var player:Node2D=null
var main: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_by_type()
	if animationType != &"" and $AnimatedSprite2D.sprite_frames.has_animation(animationType):
		$AnimatedSprite2D.animation = animationType
	#elif animationType==&"mob_fire"||animationType==&"mob_ice"||animationType==&"mob_light":
		#pass
	else:
		var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
		$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	pass # Replace with function body.
#设置形象
func setup_by_type():
	match mob_type:
		MobType.Fire:
			cu_demage=9
			cu_health=6
			cu_speed=220.0
			animationType=&"mob-fire"
		MobType.Ice:
			cu_demage=5
			cu_health=14
			cu_speed=120.0
			animationType=&"mob-ice"
		MobType.Light:
			cu_demage=2
			cu_health=9
			cu_speed=360.0
			animationType=&"mob-light"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#受伤和死亡
func take_demage(amount:int):
	cu_health-=amount
	if main != null and is_instance_valid(main):
		main.spawn_floating_text("-" + str(amount), Color(1, 0.2, 0.2), global_position + Vector2(0, -30))
	#print("ENEMY_HP:", cu_health)
	if cu_health > 0:
		play_hit_animation()
	if cu_health<=0:
		cu_speed=0;
		die_ani()
func die_ani():
	$AnimatedSprite2D.visible=false
	$DIE.visible=true
	$DIE.play()
func _on_die_animation_finished() -> void:
	$DIE.visible=false
	die()
	pass # Replace with function body.
func die():
	if main != null and is_instance_valid(main):
		main.beat_mob(3)
	queue_free()
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
	
func launch(direction: float) -> void:
	linear_velocity = Vector2(cu_speed, 0.0).rotated(direction)
	var sprite := $AnimatedSprite2D
	if linear_velocity.x < 0:
		sprite.flip_h = true
	elif linear_velocity.x > 0:
		sprite.flip_h = false
		
		
#func _on_body_entered(body: Node) -> void:
	##print("MOB body_entered -> ", body.name)
	#if body.is_in_group("player"):
		#body.take_demage(cu_demage)
		#match mob_type:
			#MobType.Fire:
				#body.apply_burn()
			#MobType.Ice:
				#body.apply_cold()
			#MobType.Light:
				#body.apply_electric()
#攻击和受击
func apply_effect_to_player(body:Node):
	body.take_demage(cu_demage)
	match mob_type:
			MobType.Fire:
				body.apply_burn()
			MobType.Ice:
				body.apply_cold()
			MobType.Light:
				body.apply_electric()
func play_hit_animation() -> void:
	var sprite := $AnimatedSprite2D
	match mob_type:
		MobType.Fire:
				sprite.animation = &"fire-hit"
		MobType.Ice:
				sprite.animation = &"ice-hit"
		MobType.Light:
				sprite.animation = &"light-hit"
	sprite.play()
func _on_animated_sprite_2d_animation_finished() -> void:
	#print("受击动画结束--怪物")
	var cur : StringName =$AnimatedSprite2D.animation
	if cur == "fire-hit" or cur == "ice-hit" or cur == "light-hit":
		match mob_type:
			MobType.Fire:
				$AnimatedSprite2D.animation = &"mob-fire"
			MobType.Ice:
				$AnimatedSprite2D.animation = &"mob-ice"
			MobType.Light:
				$AnimatedSprite2D.animation = &"mob-light"
		$AnimatedSprite2D.play()
	pass # Replace with function body.
