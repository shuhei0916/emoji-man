extends GutTest
## つぶれる（ムギュ）のテスト。感情ではなく一瞬の反射として顔と見た目が変わる

const PlayerScene := preload("res://src/player/player.tscn")

var player: Player


func before_each():
	add_child_autofree(EmotionWorld.new())
	player = PlayerScene.instantiate()
	player.wants = [&"star"]
	add_child_autofree(player)


func _face_of(c: EmojiCharacter) -> String:
	c._refresh_face()
	return c.get_node("FaceLabel").text


func test_つぶれると感情に関係なく顔がつぶれた顔になる():
	player.take_item(&"star")
	player.squash()
	assert_eq(_face_of(player), "😖")


func test_つぶれてから0_3秒たつまではつぶれた顔のまま():
	player.take_item(&"star")
	player.squash()
	player._process(0.2)
	assert_eq(_face_of(player), "😖")


func test_つぶれてから0_3秒たつと感情の顔に戻る():
	player.take_item(&"star")
	player.squash()
	player._process(0.3)
	assert_eq(_face_of(player), "😄")


func _sprite() -> AnimatedSprite2D:
	return player.get_node("AnimatedSprite2D")


func test_つぶれた瞬間は見た目が縦に縮んで横に広がる():
	player.squash()
	assert_lt(_sprite().scale.y, 1.0)
	assert_gt(_sprite().scale.x, 1.0)


func test_つぶれると顔も頭のほうへ寄る():
	var face: Label = player.get_node("FaceLabel")
	var y := face.position.y
	player.squash()
	assert_lt(face.position.y, y)


func test_つぶれた見た目は時間とともに戻っていく():
	player.squash()
	var squashed := _sprite().scale.y
	player._process(0.15)
	assert_between(_sprite().scale.y, squashed + 0.01, 0.99)
	player._process(0.15)
	assert_eq(_sprite().scale, Vector2.ONE)
	assert_eq(_sprite().position, Vector2.ZERO)


## y の位置に、normal の向きを表にした無限に広い壁を置く
func _boundary_at(y: float, normal: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	shape.shape = WorldBoundaryShape2D.new()
	shape.shape.normal = normal
	body.add_child(shape)
	body.position = Vector2(0, y)
	return add_child_autofree(body)


func test_ジャンプして上のブロックに頭をぶつけるとつぶれる():
	_boundary_at(-100, Vector2.DOWN)
	player.velocity = Vector2(0, -750)
	await wait_physics_frames(10)
	assert_eq(_face_of(player), "😖")


func test_頭をぶつけずにジャンプしてもつぶれない():
	player.velocity = Vector2(0, -750)
	await wait_physics_frames(10)
	assert_eq(_face_of(player), "😐")


func test_怒っていて頭上の木箱を壊したときはつぶれない():
	add_child_autofree(preload("res://src/npc/npc.tscn").instantiate())
	get_tree().get_first_node_in_group(EmotionWorld.GROUP).item_taken(&"npc", &"star")
	var box: BreakableBox = add_child_autofree(preload("res://src/gimmick/breakable_box.tscn").instantiate())
	box.position = Vector2(0, -100)
	player.velocity = Vector2(0, -750)
	await wait_physics_frames(10)
	assert_false(is_instance_valid(box))
	assert_ne(_face_of(player), "😖")


func test_キャラクターが上から落ちてきてもすり抜けてどちらもつぶれない():
	_boundary_at(46, Vector2.UP)
	var npc: Npc = add_child_autofree(preload("res://src/npc/npc.tscn").instantiate())
	npc.position = Vector2.ZERO
	player.position = Vector2(0, -200)
	await wait_seconds(0.6)
	assert_almost_eq(player.position.y, npc.position.y, 2.0)
	assert_eq(_face_of(player), "😐")
	assert_eq(_face_of(npc), "😐")


func _body(c: EmojiCharacter = player) -> CollisionShape2D:
	return c.get_node("CollisionShape2D")


## 当たり判定の上端・下端のy座標（キャラクターから見て）
func _body_top(c: EmojiCharacter = player) -> float:
	return _body(c).position.y - _body(c).shape.size.y / 2.0


func _body_bottom(c: EmojiCharacter = player) -> float:
	return _body(c).position.y + _body(c).shape.size.y / 2.0


func test_つぶれると当たり判定も縦に縮む():
	var height: float = _body().shape.size.y
	var width: float = _body().shape.size.x
	player.squash()
	assert_lt(_body().shape.size.y, height)
	assert_eq(_body().shape.size.x, width)


func test_つぶれた当たり判定は時間とともに戻る():
	var height: float = _body().shape.size.y
	var y := _body().position.y
	player.squash()
	player._process(0.3)
	assert_eq(_body().shape.size.y, height)
	assert_eq(_body().position.y, y)


func test_つぶれても同じシーンの他のキャラクターの当たり判定は変わらない():
	var other: Player = add_child_autofree(PlayerScene.instantiate())
	var height: float = _body(other).shape.size.y
	player.squash()
	assert_eq(_body(other).shape.size.y, height)


## 見た目の頭のてっぺんのy座標
func _head_y() -> float:
	var sprite := _sprite()
	var height := sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height()
	return sprite.position.y - height / 2.0 * sprite.scale.y


func _bump_head() -> void:
	_boundary_at(-100, Vector2.DOWN)
	player.velocity = Vector2(0, -750)
	await wait_until(func() -> bool: return _face_of(player) == "😖", 1.0)


func test_天井に頭をぶつけてつぶれるときは頭が動かず足元が上がる():
	var top := _body_top()
	var bottom := _body_bottom()
	await _bump_head()
	assert_almost_eq(_body_top(), top, 0.01)
	assert_lt(_body_bottom(), bottom - 10.0)


func test_天井に頭をぶつけてつぶれるときは見た目の頭もほとんど動かない():
	# 空中ではジャンプの絵になるので、先に合わせておく
	_sprite().play(&"jump")
	var head := _head_y()
	await _bump_head()
	assert_almost_eq(_head_y(), head, 2.0)
	assert_lt(_sprite().scale.y, 0.9)
