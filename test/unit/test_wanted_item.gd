extends GutTest

const ItemScene := preload("res://src/item/wanted_item.tscn")
const PlayerScene := preload("res://src/player/player.tscn")

var item: WantedItem
var player: Player


func before_each():
	add_child_autofree(EmotionWorld.new())
	item = add_child_autofree(ItemScene.instantiate())
	player = PlayerScene.instantiate()
	player.wants = [item.item_id]
	add_child_autofree(player)


func test_キャラクターが触れるとそのアイテムを手に入れる():
	item._on_body_entered(player)
	assert_eq(player.get_node("FaceLabel").text, "😄")


func test_キャラクターが触れるとアイテムは消える():
	item._on_body_entered(player)
	assert_true(item.is_queued_for_deletion())


func test_キャラクター以外が触れても消えない():
	var other: StaticBody2D = add_child_autofree(StaticBody2D.new())
	item._on_body_entered(other)
	assert_false(item.is_queued_for_deletion())
