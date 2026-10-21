extends GutTest

const ME := &"me"

var prefs: Preferences


func before_each():
	prefs = Preferences.new()


func test_自分に良いことが起きると幸せ():
	assert_eq(Appraisal.appraise(ME, ME, true, prefs), Face.Mood.HAPPY)


func test_自分に悪いことが起きると悲しい():
	assert_eq(Appraisal.appraise(ME, ME, false, prefs), Face.Mood.SAD)


func test_好きな人に良いことが起きると嬉しい():
	prefs.like(&"alice")
	assert_eq(Appraisal.appraise(ME, &"alice", true, prefs), Face.Mood.HAPPY_FOR)


func test_好きな人に悪いことが起きると気の毒():
	prefs.like(&"alice")
	assert_eq(Appraisal.appraise(ME, &"alice", false, prefs), Face.Mood.PITY)


func test_嫌いな人に良いことが起きると妬ましい():
	prefs.dislike(&"bob")
	assert_eq(Appraisal.appraise(ME, &"bob", true, prefs), Face.Mood.RESENTMENT)


func test_嫌いな人に悪いことが起きるとざまあみろ():
	prefs.dislike(&"bob")
	assert_eq(Appraisal.appraise(ME, &"bob", false, prefs), Face.Mood.GLOATING)


func test_どうでもいい人に何が起きても反応しない():
	assert_eq(Appraisal.appraise(ME, &"carol", true, prefs), Appraisal.NO_REACTION)
	assert_eq(Appraisal.appraise(ME, &"carol", false, prefs), Appraisal.NO_REACTION)
