extends Node2D

@export var lifetime: float = 0.6
@export var rise_speed: float = 40.0
var velocity := Vector2(0, -1)
var time_left := 0.0

func setup(content: String, color: Color, start_pos: Vector2) -> void:
	global_position = start_pos
	$Text.text = content
	$Text.modulate = color
	$Timer.start(0.6)

func _process(delta: float) -> void:
	#time_left -= delta
	#position += velocity * rise_speed * delta
#
	## 渐隐
	#$Text.modulate.a = max(0.0, time_left / lifetime)
#
	#if time_left <= 0.0:
		#queue_free()
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
