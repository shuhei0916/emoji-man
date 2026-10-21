class_name Appraisal
extends RefCounted
## 出来事に対する感情を、OCCモデルに沿って評価する。
##
## | 誰に起きたか | 良いこと       | 悪いこと      |
## |--------------|----------------|---------------|
## | 自分         | HAPPY 😄       | SAD 😢        |
## | 好きな人     | HAPPY_FOR 🥰   | PITY 🥺       |
## | 嫌いな人     | RESENTMENT 😒  | GLOATING 😏   |
## | どうでもいい | 反応しない     | 反応しない    |

const NO_REACTION := -1


## observer: 出来事を見た人, subject: 出来事が起きた人, is_good: subjectにとって良いことか
static func appraise(observer: StringName, subject: StringName, is_good: bool, prefs: Preferences) -> int:
	if subject == observer:
		return Face.Mood.HAPPY if is_good else Face.Mood.SAD
	match prefs.attitude_toward(subject):
		Preferences.Attitude.LIKE:
			return Face.Mood.HAPPY_FOR if is_good else Face.Mood.PITY
		Preferences.Attitude.DISLIKE:
			return Face.Mood.RESENTMENT if is_good else Face.Mood.GLOATING
		_:
			return NO_REACTION
