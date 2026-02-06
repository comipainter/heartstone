extends Node
class_name Player

# 玩家信息
var coinRest: int
var coinLimit: int

func can_buy_minion() -> bool:
	if coinRest > 3:
		return true
	else:
		return false

func buy_minion() -> void:
	coinRest -= 3

func start_shop() -> void:
	coinRest = coinLimit

# 设置基本信息
func set_coinRest(coinRest: int) -> void:
	self.coinRest = coinRest
	
func set_coinLimit(coinLimit: int) -> void:
	self.coinLimit = coinLimit
