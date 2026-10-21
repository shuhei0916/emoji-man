class_name Preferences
extends RefCounted

enum Attitude { INDIFFERENT, LIKE, DISLIKE }

var _attitudes: Dictionary[StringName, Attitude] = {}


func like(id: StringName) -> void:
	_attitudes[id] = Attitude.LIKE


func dislike(id: StringName) -> void:
	_attitudes[id] = Attitude.DISLIKE


func attitude_toward(id: StringName) -> Attitude:
	return _attitudes.get(id, Attitude.INDIFFERENT)
