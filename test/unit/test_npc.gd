extends GutTest

const NpcScene := preload("res://src/npc/npc.tscn")

var npc: Npc


func before_each():
	npc = add_child_autofree(NpcScene.instantiate())


func test_NPCも普通の顔の絵文字を表示している():
	assert_eq(npc.get_node("FaceLabel").text, "😐")


func test_NPCが困るとNPC自身は悲しくなる():
	npc.get_in_trouble()
	assert_eq(npc.get_node("FaceLabel").text, "😢")


func test_NPCが困るとNPCを嫌っているプレイヤーはざまあみろの顔になる():
	var player: Player = preload("res://src/player/player.tscn").instantiate()
	player.dislikes = [npc.id]
	add_child_autofree(player)
	npc.get_in_trouble()
	assert_eq(player.get_node("FaceLabel").text, "😏")


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
