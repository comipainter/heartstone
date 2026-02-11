extends Node

class_name MinionToAnimation

static func check_coin_increase(minionList: Array) -> void:
	for minion in minionList:
		coin_increace(minion, minion.get_id())
		
static func check_sell(minionList: Array) -> void:
	for minion in minionList:
		sell(minion, minion.get_id())

static func coin_increace(minion: Node, id: int) -> void:
	match id:
		1:
			minion.add_animation(CardAnimation.DuoJinJianJiang.new(minion))
			
static func sell(minion: Node, id: int) -> void:
	match id:
		2:
			minion.add_animation(CardAnimation.BaiZhuanDutu.new())
