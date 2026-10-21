extends GutTest

var prefs: Preferences


func before_each():
	prefs = Preferences.new()


func test_何も登録していない相手への態度はどうでもいい():
	assert_eq(prefs.attitude_toward(&"bob"), Preferences.Attitude.INDIFFERENT)


func test_好きな相手を登録できる():
	prefs.like(&"alice")
	assert_eq(prefs.attitude_toward(&"alice"), Preferences.Attitude.LIKE)


func test_嫌いな相手を登録できる():
	prefs.dislike(&"bob")
	assert_eq(prefs.attitude_toward(&"bob"), Preferences.Attitude.DISLIKE)
