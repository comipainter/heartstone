extends Control
# 卡牌种类
var cardType = GameManager.CARDTYPE.MAGIC

# 节点信息
@onready var nameLabel = $Panel/NameLabel
@onready var costLabel = $Panel/CostLabel
@onready var descriptionLabel = $Panel/DescriptionLabel

# 附着参数
var velocity = Vector2.ZERO
var damping = 0.35
var stiffness = 500

# 法术运动状态
enum MOVESTATE{IDLE, FOLLOW, DRAG}
var moveState=MOVESTATE.IDLE
@export var follow_target:Node

# 法术归属状态
enum BELONGSTATE{NONE, SHOP, HAND, DESK, FIGHT}
var belongState=BELONGSTATE.SHOP

# 法术信息
var magicInfo: Dictionary

func _ready():
	set_process(true)
	use_magicInfo()

func _process(delta: float) -> void:
	match moveState:
		MOVESTATE.DRAG:
			var target_position = get_global_mouse_position()-size/2
			global_position = global_position.lerp(target_position, 0.4)
		MOVESTATE.FOLLOW:
			if follow_target != null:
				var target_position = follow_target.global_position
				var displacement = target_position - global_position
				var distance = displacement.length()
				if distance < 2.0:  # 已经足够达到目标，调整为idle状态
					global_position = target_position
					velocity = Vector2.ZERO
					moveState = MOVESTATE.IDLE
				else:
					var force = displacement * stiffness
					velocity += force * delta
					velocity *= (1.0 - damping)
					global_position += velocity * delta
# 逻辑方法
func is_idle() -> bool:
	if self.moveState == MOVESTATE.IDLE:
		return true
	return false

func is_in_buy_region() -> bool:
	return GameManager.is_in_region(GameManager.shopScene.buyRegionNode, self)
	
func is_in_desk_region() -> bool:
	return GameManager.is_in_region(GameManager.shopScene.deskRegionNode, self)

func _on_button_button_down() -> void:
	if belongState == BELONGSTATE.FIGHT:
		return
	self.set_move_drag()
	
func _on_button_button_up() -> void:
	match belongState:
		BELONGSTATE.SHOP:
			if is_in_buy_region() == true:
				print("购买法术")
				if GameManager.shopScene.can_buy_magic(self.get_cost()):
					GameManager.shopScene.buy_magic(self.get_cost())
					GameManager.shopScene.shopCardNode.remove_card(self)
					GameManager.shopScene.handCardNode.add_card(self)
				else:
					print("购买失败，金币不足")
			else:
				GameManager.shopScene.shopCardNode.resort_card(self)
		BELONGSTATE.HAND:
			if is_in_desk_region() == true:
				print("使用法术")
				GameManager.shopScene.handCardNode.remove_card(self)
				self.use()
		BELONGSTATE.DESK:
			GameManager.shopScene.deskCardNode.resort_card(self)
	self.set_move_follow()
	
# 使用法术
func use() -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 1).set_ease(Tween.EASE_OUT)
	tween.finished.connect(queue_free)
	return tween.finished
	
# 配置方法 
func get_cardInfo() -> Dictionary:
	return self.magicInfo

func set_cardInfo(cardInfo: Dictionary) -> void:
	self.magicInfo = cardInfo

func set_magicInfo(magicInfo: Dictionary) -> void:
	self.magicInfo = magicInfo

func use_magicInfo() -> void:
	self.nameLabel.text = self.magicInfo["magic_name"]
	self.costLabel.text = str(self.magicInfo["cost"])
	self.descriptionLabel.text = self.magicInfo["description"]

func get_cost() -> int:
	return self.magicInfo["cost"]

func set_follow_target(target: Node) -> void:
	follow_target = target

func get_follow_target() -> Node:
	return follow_target
	
func set_belong_none() -> void:
	belongState=BELONGSTATE.NONE

func is_belong_shop() -> bool:
	return belongState == BELONGSTATE.SHOP
	
func is_belong_hand() -> bool:
	return belongState == BELONGSTATE.HAND

func is_belong_desk() -> bool:
	return belongState == BELONGSTATE.DESK

func set_belong_shop() -> void:
	belongState=BELONGSTATE.SHOP
	
func set_belong_hand() -> void:
	belongState=BELONGSTATE.HAND
	
func set_belong_desk() -> void:
	belongState=BELONGSTATE.DESK
	
func set_belong_fight() -> void:
	belongState=BELONGSTATE.FIGHT
	
func set_move_follow() -> void:
	moveState = MOVESTATE.FOLLOW
	
func set_move_drag() -> void:
	moveState = MOVESTATE.DRAG
	
func set_move_idle() -> void:
	moveState = MOVESTATE.IDLE
