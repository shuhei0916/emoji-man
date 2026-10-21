class_name Face
extends RefCounted

enum Mood { NEUTRAL, HAPPY }

var mood := Mood.NEUTRAL


func obtain_wanted_item() -> void:
	mood = Mood.HAPPY
