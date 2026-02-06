extends Control

@export var initCardNum: int
@export var separationSize: int
@export var cardStartPosition: Vector2
@onready var cardContainerNode = $ScrollContainer/CardContainer
@onready var minionTemplate = GameManager.minionTemplate
var cardList = []

func _ready() -> void:
	cardContainerNode.add_theme_constant_override("separation", separationSize)
	generate_card(initCardNum)

func generate_card(num: int) -> void:
	for i in range(num):
		# 先添加卡牌占位箱
		var cardBox = Control.new()
		cardContainerNode.add_child(cardBox)
		
		# 再创建卡牌，使其跟随占位箱
		var card = minionTemplate.instantiate()
		GameManager.shopScene.cardsNode.add_child(card)
		card.set_follow_target(cardBox)
		card.set_move_follow()
		card.set_belong_shop()
		card.global_position = cardStartPosition
		
		# 添加随从信息
		var randomMinionInfo = MinionInfo.choose_random_minion(GameManager.allMinionInfo)
		card.set_minionInfo(randomMinionInfo)
		
		# 添加卡牌列表
		cardList.append(card)
		
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
