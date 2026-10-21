class_name Appraisal
extends RefCounted
## 出来事に対する感情を、OCCモデル（GAMYGDALA風）に沿って評価する。
##
## 自分に起きた出来事:
## | 誰が引き起こしたか   | 良いこと       | 悪いこと      |
## |----------------------|----------------|---------------|
## | 自分 / 誰でもない    | HAPPY 😄       | SAD 😢        |
## | 他人                 | GRATITUDE 🥹   | ANGER 😠      |
##
## 他人に起きた出来事:
## | 誰に起きたか | 良いこと       | 悪いこと      |
## |--------------|----------------|---------------|
## | 好きな人     | HAPPY_FOR 🥰   | PITY 🥺       |
## | 嫌いな人     | RESENTMENT 😒  | GLOATING 😏   |
## | どうでもいい | 反応しない     | 反応しない    |

const NO_REACTION := -1


## observer: 出来事を見た人, subject: 出来事が起きた人, is_good: subjectにとって良いことか
## cause: 出来事を引き起こした人（空なら誰のせいでもない）
static func appraise(observer: StringName, subject: StringName, is_good: bool, prefs: Preferences, cause := &"") -> int:
	if subject == observer:
		return _appraise_own(observer, is_good, cause)
	match prefs.attitude_toward(subject):
		Preferences.Attitude.LIKE:
			return Face.Mood.HAPPY_FOR if is_good else Face.Mood.PITY
		Preferences.Attitude.DISLIKE:
			return Face.Mood.RESENTMENT if is_good else Face.Mood.GLOATING
		_:
			return NO_REACTION


static func _appraise_own(observer: StringName, is_good: bool, cause: StringName) -> int:
	var caused_by_other := cause != &"" and cause != observer
	if caused_by_other:
		return Face.Mood.GRATITUDE if is_good else Face.Mood.ANGER
	return Face.Mood.HAPPY if is_good else Face.Mood.SAD
