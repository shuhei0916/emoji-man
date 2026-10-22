extends GutTest

const DELTA := 1.0 / 60.0


func test_右に入力すると右向きに一定の速さで動く():
	var v := Player.compute_velocity(Vector2.ZERO, 1.0, false, true, DELTA)
	assert_eq(v.x, Player.SPEED)


func test_床の上でジャンプすると上向きの速度になる():
	var v := Player.compute_velocity(Vector2.ZERO, 0.0, true, true, DELTA)
	assert_eq(v.y, Player.JUMP_VELOCITY)


func test_空中では重力で下向きに加速する():
	var v := Player.compute_velocity(Vector2.ZERO, 0.0, false, false, DELTA)
	assert_almost_eq(v.y, Player.GRAVITY * DELTA, 0.001)


func test_空中ではジャンプできない():
	var v := Player.compute_velocity(Vector2.ZERO, 0.0, true, false, DELTA)
	assert_almost_eq(v.y, Player.GRAVITY * DELTA, 0.001)


func test_速さの倍率を掛けられる():
	var v := Player.compute_velocity(Vector2.ZERO, 1.0, false, true, DELTA, 0.5)
	assert_eq(v.x, Player.SPEED * 0.5)


func test_ジャンプの高さを倍率どおりにできる():
	var v := Player.compute_velocity(Vector2.ZERO, 0.0, true, true, DELTA, 1.0, 1.5)
	# 最高到達点 v^2 / 2g が通常の1.5倍になる
	var normal_height := Player.JUMP_VELOCITY ** 2 / (2.0 * Player.GRAVITY)
	assert_almost_eq(v.y ** 2 / (2.0 * Player.GRAVITY), normal_height * 1.5, 0.001)
	assert_lt(v.y, 0.0, "上向き")
