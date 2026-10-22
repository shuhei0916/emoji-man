class_name GoalFlag
extends Area2D
## ステージのゴール。プレイヤーが触れるとゴールに着いたことを知らせる。

signal reached


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		reached.emit()
