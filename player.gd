extends Node
class_name Player

# 玩家信息
var coinRest: int
var coinLimit: int

# 逻辑方法
func can_buy_minion() -> bool:
	if coinRest > 3:
		return true
	else:
		return false
		
func update_coinsLabel() -> void:
	GameManager.shopScene.coinLabelNode.set_coin(coinRest, coinLimit)

func buy_minion() -> void:
	coinRest -= 3
	update_coinsLabel()

func start_shop() -> void:
	coinRest = coinLimit
	update_coinsLabel()

# 配置方法
func set_coinRest(coinRest: int) -> void:
	self.coinRest = coinRest
	
func set_coinLimit(coinLimit: int) -> void:
	self.coinLimit = coinLimit
