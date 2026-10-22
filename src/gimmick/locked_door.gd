class_name LockedDoor
extends StaticBody2D
## 鍵を持ったキャラクターが触れると開く（消える）扉。鍵は使うとなくなる。

@export var key_id := &"key"


func _on_body_entered(body: Node2D) -> void:
	if body is not EmojiCharacter or body.held == null or body.held.item_id != key_id:
		return
	var key: WantedItem = body.held
	body.held = null
	key.queue_free()
	queue_free()
