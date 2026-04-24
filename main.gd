extends Node
@export var mob_scene: PackedScene
@export var item_scene:PackedScene
@export var special_mob_scene:PackedScene
@export var buff_scene:PackedScene
@export var buff2_scene:PackedScene
@export var buff3_scene:PackedScene
@export var floating_text_scene: PackedScene
var score
@export var mob_spawn_initial := 0.75
@export var special_spawn_initial:= 13.0
#@export var mob_spawn_min := 0.2
#@export var mob_spawn_decay := 0.9
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HUD.update_stats($Player.health, $Player.max_health, $Player.energy, $Player.max_energy)
	if $Player.energy==$Player.max_energy:
		$Player.energy=0
		beat_mob(10)
	$HUD.update_status_icons($Player.is_burning, $Player.is_cold, $Player.is_electric, $Player.is_wet)
	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$SpecialMobTimer.stop()
	$ItemsTimer.stop()
	$BuffTimer.stop()
	$Buff2Timer.stop()
	$Buff3Timer.stop()
	$DeathSound.play()
	$HUD.show_game_over()
	$Music.stop()
	$HUD/GameUI.hide()
	$MobTimer/DifficultyTimer.stop()

func new_game():
	score = 0
	$MobTimer.wait_time = mob_spawn_initial
	$SpecialMobTimer.wait_time=special_spawn_initial
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$Player.health=$Player.max_health
	$Player.energy=0
	$Player.ATK=$Player.base_ATK
	get_tree().call_group("mobs", "queue_free")
	$StartTimer.start()
	$Music.play()
	$HUD/GameUI.show()
#生成怪物
func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	mob.mob_type = _pick_mob_type()
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position

	# 1. 计算移动方向
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	 
	add_child(mob)
	var velocity = Vector2(mob.cu_speed, 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	var sprite = mob.get_node("AnimatedSprite2D") 
	if sprite:
		if mob.linear_velocity.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	mob.main = self
func _pick_mob_type() -> int:
	var r := randf()
	if r < 0.6:
		return 0 # MobType.Fire
	elif r < 0.7:
		return 1 # MobType.Ice
	else:
		return 2 # MobType.Light
#计时加分
func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$MobTimer/DifficultyTimer.start()
	$ScoreTimer.start()
	$ItemsTimer.start()
	$BuffTimer.start()
	$Buff2Timer.start()
	$Buff3Timer.start()
	$SpecialMobTimer.start()

#物品刷新
func _on_items_timer_timeout() -> void:
	var item:=item_scene.instantiate()
	var x:=randi_range(30,770)
	var y:=randi_range(20,1170)
	item.global_position = Vector2(x, y)
	add_child(item)
	
#生成buff
func _on_buff_timer_timeout() -> void:
	var buff:=buff_scene.instantiate()
	var x:=randi_range(50,750)
	var y:=randi_range(50,1150)
	buff.global_position = Vector2(x, y)
	add_child(buff)
	pass 
func _on_buff_2_timer_timeout() -> void:
	var buff2:=buff2_scene.instantiate()
	var x:=randi_range(50,750)
	var y:=randi_range(50,1150)
	buff2.global_position = Vector2(x, y)
	add_child(buff2)
	pass # Replace with function body.
func _on_buff_3_timer_timeout() -> void:
	var buff3:=buff3_scene.instantiate()
	var x:=randi_range(50,750)
	var y:=randi_range(50,1150)
	buff3.global_position = Vector2(x, y)
	add_child(buff3)
	pass # Replace with function body.

#击倒怪物加分
func beat_mob(sco:int) -> void:
	score += sco
	$HUD.update_score(score)
	pass # Replace with function body.

#特殊怪物刷新
func _on_special_mob_timer_timeout() -> void:
	if special_mob_scene == null:
		return
	var pair := special_mob_scene.instantiate()
	add_child(pair)
	pass # Replace with function body.

#难度随时间上涨
func _on_difficulty_timer_timeout() -> void:
	$MobTimer.wait_time = max(0.15, $MobTimer.wait_time * 0.85)
	$SpecialMobTimer.wait_time = max(5, $SpecialMobTimer.wait_time * 0.95)
	pass # Replace with function body.

#死亡字体
func spawn_floating_text(content: String, color: Color, world_pos: Vector2) -> void:
	if floating_text_scene == null:
		return
	var t = floating_text_scene.instantiate()
	add_child(t)
	t.setup(content, color, world_pos)
