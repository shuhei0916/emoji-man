class_name BreakableBox
extends StaticBody2D
## 怒っているキャラクターがぶつかると壊れる箱。


## ぶつかったキャラクターが箱を壊せる気分なら壊す。壊れたら true を返す
func hit_by(character: EmojiCharacter) -> bool:
	if not MoodBuff.from_emotions(character.agent.get_emotional_state()).can_break:
		return false
	queue_free()
	return true
