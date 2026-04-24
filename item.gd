extends Area2D


func _ready() -> void:
	pass

	
func _on_area_entered(body: Node) -> void:
	if body.is_in_group("player"):  # 也可以判断类名 / 直接判断节点名
		if body.has_method("on_item_picked"):
			body.on_item_picked()
		body.change_energy(6)
		body.apply_wet(5.0)
		queue_free()


func _on_item_timr_timeout() -> void:
	queue_free()
	pass # Replace with function body.
