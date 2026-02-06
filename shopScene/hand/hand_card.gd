extends Control

@export var separationSize: int
@onready var cardContainerNode = $ScrollContainer/CardContainer

var cardList = []

func _ready() -> void:
	cardContainerNode.add_theme_constant_override("separation", separationSize)

func add_card(card: Node) -> void:
	# 先添加卡牌占位箱
	var cardBox = Control.new()
	cardContainerNode.add_child(cardBox)
	
	# 再使其跟随占位箱
	card.set_follow_target(cardBox)
	card.set_move_follow()
	card.set_belong_hand()

	# 添加卡牌列表
	cardList.append(card)
	
	# 使所有节点开始重新跟随
	for cardInList in cardList:
		cardInList.set_move_follow()

func remove_card(card: Node) -> void:
	# 先删除卡牌占位箱
	var cardBox = card.get_follow_target()
	cardContainerNode.remove_child(cardBox)
	cardBox.queue_free()
	
	card.set_move_idle()
	card.set_belong_none()
	# 从卡牌列表中删除
	cardList.erase(card)
	# 使剩余卡牌开始跟随
	for cardInList in cardList:
		cardInList.set_move_follow()
