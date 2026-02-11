extends Control

@export var separationSize: int
@export var cardStartPosition: Vector2
@onready var cardContainerNode = $ScrollContainer/CardContainer

var minionTemplate = GameManager.minionTemplate
var cardList = []

func _ready() -> void:
	cardContainerNode.add_theme_constant_override("separation", separationSize)

func is_all_idle() -> bool:
	for card in cardList:
		if not card.is_idle():
			return false
	return true
	
func follow() -> void:
	# 使所有节点开始重新跟随
	for cardInList in cardList:
		cardInList.set_move_follow()

func generate_cards(handCardInfoList: Array) -> void:
	for cardInfo in handCardInfoList:
		var card: Node
		if cardInfo["type"] == "minion":
			card = self.minionTemplate.instantiate()
		else:
			card = self.magicTemplate.instantiate()
		card.set_cardInfo(cardInfo)
		GameManager.fightScene.cardsNode.add_child(card)
		card.global_position = cardStartPosition
		self.add_card(card)

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
	self.follow()

func remove_card(card: Node) -> void:
	# 先删除卡牌占位箱
	var cardBox = card.get_follow_target()
	cardContainerNode.remove_child(cardBox)
	cardBox.queue_free()
	
	card.set_move_idle()
	card.set_belong_none()
	# 从卡牌列表中删除
	cardList.erase(card)
	self.follow()
