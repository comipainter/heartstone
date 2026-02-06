extends Node

class_name Minion

var id: int
var minion_name: String
var race: int
var attack: int
var health: int
var description: String

func _init(p_id, p_minion_name, p_race, p_atk, p_hp, p_desc):
	id = p_id
	minion_name = p_minion_name
	race = p_race
	attack = p_atk
	health = p_hp
	description = p_desc
