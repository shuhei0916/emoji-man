extends GutTest
## 拾う・投げる・受け取るアイテムのテスト

const ItemScene := preload("res://src/item/wanted_item.tscn")
const PlayerScene := preload("res://src/player/player.tscn")
const NpcScene := preload("res://src/npc/npc.tscn")

var item: WantedItem
var player: Player


func before_each():
	add_child_autofree(EmotionWorld.new())
	item = add_child_autofree(ItemScene.instantiate())
	player = PlayerScene.instantiate()
	player.wants = [item.item_id]
	add_child_autofree(player)


func _npc(wants: Array[StringName]) -> Npc:
	var npc: Npc = NpcScene.instantiate()
	npc.wants = wants
	return add_child_autofree(npc)


func _face_of(c: EmojiCharacter) -> String:
	c._refresh_face()
	return c.get_node("FaceLabel").text


func test_プレイヤーが触れると持ち上げて欲しいものなら喜ぶ():
	item._on_body_entered(player)
	assert_eq(player.held, item)
	assert_eq(item.holder, player)
	assert_false(item.is_queued_for_deletion())
	assert_eq(_face_of(player), "😄")


func test_持ち上げた物はプレイヤーと一緒に動く():
	item._on_body_entered(player)
	player.global_position = Vector2(300, 100)
	item._physics_process(1.0 / 60.0)
	assert_eq(item.global_position, player.global_position + EmojiCharacter.HOLD_OFFSET)


func test_手がふさがっていたらほかの物は拾わない():
	item._on_body_entered(player)
	var other: WantedItem = add_child_autofree(ItemScene.instantiate())
	other._on_body_entered(player)
	assert_eq(player.held, item)
	assert_null(other.holder)


func test_欲しがっているNPCが触れると受け取って消える():
	var npc := _npc([&"star"])
	item._on_body_entered(npc)
	assert_true(item.is_queued_for_deletion())
	assert_eq(_face_of(npc), "😄")


func test_欲しがっていないNPCが触れても拾わない():
	var npc := _npc([])
	item._on_body_entered(npc)
	assert_false(item.is_queued_for_deletion())
	assert_null(item.holder)


func test_人が持っている物はほかのキャラクターが触れても取られない():
	item._on_body_entered(player)
	item._on_body_entered(_npc([&"star"]))
	assert_eq(item.holder, player)
	assert_false(item.is_queued_for_deletion())


func test_投げると向いている方向へ飛び手から離れる():
	item._on_body_entered(player)
	player.facing = -1.0
	player.throw()
	assert_null(player.held)
	assert_null(item.holder)
	assert_lt(item.velocity.x, 0.0)
	assert_lt(item.velocity.y, 0.0)


func test_投げた直後は投げた人が拾い直さない():
	item._on_body_entered(player)
	player.throw()
	item._on_body_entered(player)
	assert_null(player.held)


func test_プレイヤーが投げた物をNPCが受け取るとプレイヤーに感謝する():
	item._on_body_entered(player)
	player.throw()
	var npc := _npc([&"star"])
	item._on_body_entered(npc)
	assert_eq(_face_of(npc), "🥹")


func test_キャラクター以外が触れても何も起きない():
	var other: StaticBody2D = add_child_autofree(StaticBody2D.new())
	item._on_body_entered(other)
	assert_false(item.is_queued_for_deletion())
	assert_null(item.holder)


func _joy_of(c: EmojiCharacter) -> float:
	for e in c.agent.get_emotional_state():
		if e.name == &"joy":
			return e.intensity
	return 0.0


func test_一度手に入れた物を拾い直してももう一度は喜ばない():
	item._on_body_entered(player)
	var joy := _joy_of(player)
	player.throw()
	item._ignore_left = 0.0
	item._on_body_entered(player)
	assert_eq(player.held, item)
	assert_almost_eq(_joy_of(player), joy, 0.0001)
