extends GutTest

const NpcScene := preload("res://src/npc/npc.tscn")

var npc: Npc


func before_each():
	add_child_autofree(EmotionWorld.new())
	npc = add_child_autofree(NpcScene.instantiate())


func test_NPCも普通の顔の絵文字を表示している():
	assert_eq(npc.get_node("FaceLabel").text, "😐")


func test_プレイヤーと重なってもNPCは押されない():
	var ground := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	shape.shape = WorldBoundaryShape2D.new()
	ground.add_child(shape)
	ground.position = Vector2(0, 46)
	add_child_autofree(ground)
	var player: Player = add_child_autofree(preload("res://src/player/player.tscn").instantiate())
	player.position = Vector2(10, 0)
	npc.position = Vector2.ZERO
	await wait_physics_frames(30)
	assert_almost_eq(npc.position.x, 0.0, 0.5)


func _item_at(x: float, item_id: StringName) -> WantedItem:
	var item: WantedItem = preload("res://src/item/wanted_item.tscn").instantiate()
	item.item_id = item_id
	item.position = Vector2(x, 0)
	return add_child_autofree(item)


func test_欲しいものがあればその方向へ歩く():
	npc.wants = [&"star"]
	npc.position = Vector2.ZERO
	_item_at(200, &"star")
	assert_eq(npc.walk_direction(), 1.0)


func test_欲しいものが左にあれば左へ歩く():
	npc.wants = [&"star"]
	npc.position = Vector2.ZERO
	_item_at(-200, &"star")
	assert_eq(npc.walk_direction(), -1.0)


func test_欲しくないものには近づかない():
	npc.wants = [&"star"]
	_item_at(200, &"key")
	assert_eq(npc.walk_direction(), 0.0)


func test_欲しいものの真下では止まる():
	npc.wants = [&"star"]
	npc.position = Vector2.ZERO
	_item_at(2, &"star")
	assert_eq(npc.walk_direction(), 0.0)


func _npc_with_key() -> Npc:
	var giver: Npc = NpcScene.instantiate()
	giver.id = &"giver"
	giver.wants = [&"star"]
	var key: WantedItem = preload("res://src/item/wanted_item.tscn").instantiate()
	key.item_id = &"key"
	giver.add_child(key)
	return add_child_autofree(giver)


func test_シーンで子として置いたアイテムは最初から持っている():
	var giver := _npc_with_key()
	assert_not_null(giver.held)
	assert_eq(giver.held.item_id, &"key")


func test_感謝している相手に持っている物を投げて渡す():
	var giver := _npc_with_key()
	var player: Player = add_child_autofree(preload("res://src/player/player.tscn").instantiate())
	player.global_position = Vector2(-200, 0)
	giver.global_position = Vector2.ZERO
	var key := giver.held
	giver._world.item_taken(&"giver", &"star", &"player")
	giver.give_to_benefactor()
	assert_null(giver.held)
	assert_lt(key.velocity.x, 0.0, "相手のいる左へ投げる")


func test_感謝していなければ持っている物を渡さない():
	var giver := _npc_with_key()
	giver._world.item_taken(&"giver", &"star")
	giver.give_to_benefactor()
	assert_not_null(giver.held)
