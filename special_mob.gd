extends Node2D
@export var mob_scene: PackedScene  
const SPECIAL_ANIM := &"mob-light"
var mob_a: RigidBody2D
var mob_b: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mob_a = mob_scene.instantiate()
	mob_b = mob_scene.instantiate()
	#mob_a.animationType=SPECIAL_ANIM
	#mob_b.animationType=SPECIAL_ANIM

	var viewport_size := get_viewport_rect().size
	var edge := randi_range(0, 3)
	mob_a.position = _random_edge_position(viewport_size,edge)
	mob_b.position = _random_edge_position(viewport_size,edge)
	
	var center:=viewport_size*0.5
	_set_random_inward_velocity(mob_a, center)
	_set_random_inward_velocity(mob_b, center)
	add_child(mob_a)
	add_child(mob_b)
	
func _process(delta: float) -> void:
	if not is_instance_valid(mob_a) or not is_instance_valid(mob_b):
		queue_free()
		return	
	$Light.points = [mob_a.position, mob_b.position]

	var mid := (mob_a.position + mob_b.position) * 0.5
	var dir := mob_b.position - mob_a.position
	$LightArea.global_position = mid
	$LightArea.rotation = dir.angle()
	var shape := $LightArea/CollisionShape2D.shape as RectangleShape2D
	shape.extents.x = dir.length() * 0.5
	shape.extents.y = 7.0  # 线宽，可调
#消灭怪物
func _on_light_area_body_entered(body: Node2D) -> void:
	if body == mob_a or body == mob_b:
		return
	if body.is_in_group("mobs"):
		body.queue_free()
	pass # Replace with function body.
#检测角色造成伤害
func _on_light_area_area_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_demage(10)
	pass # Replace with function body.
#随机角度方向
func _set_random_inward_velocity(mob: RigidBody2D, center: Vector2) -> void:
	var dir := (center - mob.global_position).normalized()
	var angle_offset := randf_range(-PI / 5.0, PI / 5.0) 
	dir = dir.rotated(angle_offset)
	var speed := randf_range(150.0, 200.0)
	mob.linear_velocity = dir * speed
func _random_edge_position(viewport_size: Vector2, edge) -> Vector2:
	var x := 0.0
	var y := 0.0
	match edge:
		0:  # 上边
			x = randf_range(0.0, viewport_size.x)
			y = 0.0
		1:  # 下边
			x = randf_range(0.0, viewport_size.x)
			y = viewport_size.y
		2:  # 左边
			x = 0.0
			y = randf_range(0.0, viewport_size.y)
		3:  # 右边
			x = viewport_size.x
			y = randf_range(0.0, viewport_size.y)
	return Vector2(x, y)
