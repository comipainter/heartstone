extends Control

@export var separationSize: int
@export var cardStartPosition: Vector2
@onready var cardContainerNode = $ScrollContainer/CardContainer

var minionTemplate = GameManager.minionTemplate
var cardList = []

func _ready() -> void:
	cardContainerNode.add_theme_constant_override("separation", separationSize)

func generate_cards() -> void:
	var deskCardInfoList = GameManager.deskCardInfoList
	for cardInfo in deskCardInfoList:
		var card: Node
		if cardInfo["type"] == "minion":
			card = self.minionTemplate.instantiate()
		else:
			card = self.magicTemplate.instantiate()
		card.set_cardInfo(cardInfo)
		GameManager.shopScene.cardsNode.add_child(card)
		card.global_position = cardStartPosition
		self.add_card(card)

func add_card(card: Node) -> void:
	# 先添加卡牌占位箱
	var cardBox = Control.new()
	cardContainerNode.add_child(cardBox)
	
	# 再使其跟随占位箱
	card.set_follow_target(cardBox)
	card.set_move_follow()
	card.set_belong_desk()
	
	# 添加卡牌列表
	cardList.append(card)
	
	# 使所有节点开始重新跟随
	for cardInList in cardList:
		cardInList.set_move_follow()

func resort_card(card: Node) -> void:
	var cardBox = card.get_follow_target()
	
	# 根据位置寻找插入点
	var leftcount = 0
	for i in range(cardContainerNode.get_child_count()):
		var otherBox = cardContainerNode.get_child(i)
		if otherBox == cardBox:
			continue
		if otherBox.global_position.x < card.global_position.x:
			leftcount += 1
		else:
			break
	# 插入
	cardContainerNode.move_child(cardBox, leftcount)
	# 使所有节点开始重新跟随
	for cardInList in cardList:
		cardInList.set_move_follow()
