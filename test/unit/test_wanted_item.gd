extends GutTest

const ItemScene := preload("res://src/item/wanted_item.tscn")
const PlayerScene := preload("res://src/player/player.tscn")

var item: WantedItem
var player: Player


func before_each():
	item = add_child_autofree(ItemScene.instantiate())
	player = add_child_autofree(PlayerScene.instantiate())


func test_プレイヤーが触れるとプレイヤーが幸せになる():
	item._on_body_entered(player)
	assert_eq(player.face.mood, Face.Mood.HAPPY)


func test_プレイヤーが触れるとアイテムは消える():
	item._on_body_entered(player)
	assert_true(item.is_queued_for_deletion())


func test_プレイヤー以外が触れても消えない():
	var other: StaticBody2D = add_child_autofree(StaticBody2D.new())
	item._on_body_entered(other)
	assert_false(item.is_queued_for_deletion())
