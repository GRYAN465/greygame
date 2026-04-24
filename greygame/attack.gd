extends Area2D
var player: Node = null
var main: Node = null
var angle: float = 0.0
@export var orbit_radius: float = 80.0
@export var angular_speed: float = 4.0  # 弧度/秒，可以调整转速

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	# 角度累加，控制转速
	angle += angular_speed * delta

	# 以玩家为圆心做圆周运动
	var offset := Vector2(orbit_radius, 0).rotated(angle)
	global_position = player.global_position + offset

	var dir_from_player:=Vector2(global_position - player.global_position).normalized()
	rotation = dir_from_player.angle()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("mobs"): 
		body.take_demage(player.ATK)
		#body.queue_free()
		#if main != null and is_instance_valid(main):
			#main.beat_mob()

		
	  
