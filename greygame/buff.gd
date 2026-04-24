extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_area_entered(body: Node) -> void:
	if body.is_in_group("player"):  
		body.ATK+=1
		print("拾取buff,攻击力：",body.ATK)
		queue_free()
	pass # Replace with function body.
