class_name Npc
extends EmojiCharacter
## 欲しいものがあれば、そこへ向かってゆっくり歩くキャラクター。

## プレイヤーの速さに対する歩く速さの割合
const WALK_SPEED_RATIO := 0.4
## 欲しいものとの横の距離がこれ以下なら着いたとみなす
const ARRIVE_DISTANCE := 5.0


func _physics_process(delta: float) -> void:
	velocity = Player.compute_velocity(velocity, walk_direction(), false, is_on_floor(), delta, WALK_SPEED_RATIO)
	move_and_slide()


## 一番近い欲しいものへ向かう向き（-1, 0, 1）
func walk_direction() -> float:
	var nearest: WantedItem = null
	for item: WantedItem in get_tree().get_nodes_in_group(WantedItem.GROUP):
		if item.item_id not in wants or item.is_queued_for_deletion():
			continue
		if nearest == null or absf(item.global_position.x - global_position.x) < absf(nearest.global_position.x - global_position.x):
			nearest = item
	if nearest == null:
		return 0.0
	var dx := nearest.global_position.x - global_position.x
	if absf(dx) <= ARRIVE_DISTANCE:
		return 0.0
	return signf(dx)
