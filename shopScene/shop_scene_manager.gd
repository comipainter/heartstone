extends Control
class_name ShopSceneManager

@export var handCardNode: Node
@export var deskCardNode: Node
@export var shopCardNode: Node
@export var buyRegionNode: Node
@export var deskRegionNode: Node
@export var cardsNode: Node
@export var coinLabelNode: Node

var coinRest = GameManager.coinRest
var coinLimit = GameManager.coinLimit

func _ready() -> void:
	# 初始化信息
	GameManager.shopScene = self
	
	await get_tree().process_frame
	
	# 开始运行
	update_coin()
	shopCardNode.update_levelUp()
	shopCardNode.generate_cards(GameManager.shopCardNum)
	handCardNode.generate_cards()
	deskCardNode.generate_cards()
	
# 逻辑方法
func _on_end_button_button_up() -> void:
	var handCardsInfoList = []
	var deskCardsInfoList = []
	for card in cardsNode.get_children():
		if card.is_belong_hand():
			handCardsInfoList.append(card.get_cardInfo())
		elif card.is_belong_desk():
			deskCardsInfoList.append(card.get_cardInfo())
	GameManager.end_shop(handCardsInfoList, deskCardsInfoList)
	
func can_buy_minion() -> bool:
	if coinRest >= 3:
		return true
	else:
		return false

func buy_minion() -> void:
	coinRest -= 3
	update_coin()
	
func can_buy_magic(cost: int) -> bool:
	if coinRest >= cost:
		return true
	else:
		return false

func buy_magic(cost: int) -> void:
	coinRest -= cost
	update_coin()
	
func update_coin() -> void:
	coinLabelNode.set_coin(coinRest, coinLimit)
	
# 配置方法
func set_shopCardNum(num: int) -> void:
	self.shopCardNum = num
