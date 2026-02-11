extends Control

@export var separationSize: int
@export var cardStartPosition: Vector2
@onready var cardContainerNode = $ScrollContainer/CardContainer
@onready var levelUpNode = $LevelUp
@onready var levelUpCostLabelNode = $LevelUp/CostLabel
@onready var minionTemplate = GameManager.minionTemplate
@onready var magicTemplate = GameManager.magicTemplate
var cardList = []

func _ready() -> void:
	cardContainerNode.add_theme_constant_override("separation", separationSize)

func fresh() -> void:
	while(cardList.is_empty() == false):
		var card = cardList[0]
		remove_card(card)
		card.queue_free()
	self.generate_cards(GameManager.shopCardNum)

func update_levelUp() -> void:
	if GameManager.shopLevel == 6:
		# 设置levelUpNode为不可见
		levelUpNode.hide()
		return
	var levelUpCost = GameManager.shopLevelCost[GameManager.shopLevel]
	levelUpCostLabelNode.text = str(levelUpCost)

func generate_cards(num: int) -> void:
	for i in range(num):
		# 先添加卡牌占位箱
		var cardBox = Control.new()
		cardContainerNode.add_child(cardBox)
		
		# 再创建卡牌，使其跟随占位箱
		var card: Node
		
		# 添加随从信息
		#if i == num-1:
			#card = magicTemplate.instantiate()
			#var randomMagicInfo = MagicInfo.choose_random_magic_under_level(GameManager.allMagicInfo, GameManager.shopLevel)
			#card.set_magicInfo(randomMagicInfo)
		#else:
			#card = minionTemplate.instantiate()
			#var randomMinionInfo = MinionInfo.choose_random_minion_under_level(GameManager.allMinionInfo, GameManager.shopLevel)
			#card.set_minionInfo(randomMinionInfo)
		card = minionTemplate.instantiate()
		var randomMinionInfo = MinionInfo.choose_random_minion_under_level(GameManager.allMinionInfo, GameManager.shopLevel)
		card.set_minionInfo(randomMinionInfo)
		
		GameManager.shopScene.cardsNode.add_child(card)
		card.set_follow_target(cardBox)
		card.set_move_follow()
		card.set_belong_shop()
		card.global_position = cardStartPosition
		
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

func _on_level_button_button_up() -> void:
	if GameManager.shopLevel == 6:
		return 
	# 先检查钱够不够升级
	if GameManager.shopScene.coinRest >= GameManager.shopLevelCost[GameManager.shopLevel]:
		print("升本成功：" + str(GameManager.shopLevel) + "->" + str(GameManager.shopLevel+1))
		GameManager.shopScene.coinRest -= GameManager.shopLevelCost[GameManager.shopLevel]
		GameManager.shopLevel += 1
		update_levelUp()
		GameManager.shopScene.update_coin()
		
func _on_fresh_button_button_up() -> void:
	# 先检查钱够不够刷新
	if GameManager.shopScene.coinRest >= 1:
		print("刷新成功")
		GameManager.shopScene.coinRest -= 1
		fresh()
		GameManager.shopScene.update_coin()
