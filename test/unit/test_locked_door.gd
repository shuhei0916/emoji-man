extends GutTest
## 鍵で開く扉のテスト

const DoorScene := preload("res://src/gimmick/locked_door.tscn")
const KeyScene := preload("res://src/item/key.tscn")
const StarScene := preload("res://src/item/wanted_item.tscn")
const PlayerScene := preload("res://src/player/player.tscn")

var door: LockedDoor
var player: Player


func before_each():
	add_child_autofree(EmotionWorld.new())
	door = add_child_autofree(DoorScene.instantiate())
	player = add_child_autofree(PlayerScene.instantiate())


func test_鍵を持ったキャラクターが触れると開き鍵はなくなる():
	var key: WantedItem = add_child_autofree(KeyScene.instantiate())
	player.pick_up(key)
	door._on_body_entered(player)
	assert_true(door.is_queued_for_deletion())
	assert_true(key.is_queued_for_deletion())
	assert_null(player.held)


func test_何も持っていなければ開かない():
	door._on_body_entered(player)
	assert_false(door.is_queued_for_deletion())


func test_鍵以外の物を持っていても開かない():
	player.pick_up(add_child_autofree(StarScene.instantiate()))
	door._on_body_entered(player)
	assert_false(door.is_queued_for_deletion())
