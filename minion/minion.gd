extends Control
# 卡牌种类
var cardType = GameManager.CARDTYPE.MINION

# 节点信息
@onready var attackLabel = $AttackLabel
@onready var healthLabel = $HealthLabel
@onready var minionSprite = $Sprite/MinionSprite

# 附着参数
var velocity = Vector2.ZERO
var damping = 0.35
var stiffness = 500

# 随从运动状态
enum MOVESTATE{IDLE, FOLLOW, DRAG}
var moveState=MOVESTATE.IDLE
@export var follow_target:Node

# 随从归属状态
enum BELONGSTATE{NONE, SHOP, HAND, DESK, FIGHT}
var belongState=BELONGSTATE.SHOP

# 随从动画队列
var animationQueueManager = AnimationQueueManager.new()

# 随从信息
var minionInfo: Dictionary

# 鼠标悬停判断
var hover_start_time = 0
const HOVER_DURATION_MS = 500
var is_entered: bool
var is_hovering: bool
var originMinionNode: Node

func _ready():
	set_process(true)
	use_minionInfo()

func _process(delta: float) -> void:
	animationQueueManager.play() # 启用动画播放
	if is_entered and not is_hovering:
		var elapsed = Time.get_ticks_msec() - hover_start_time
		if elapsed >= HOVER_DURATION_MS:
			is_hovering = true
			hover()
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
# 添加动画
func add_animation(animation: CardAnimation) -> void:
	animationQueueManager.add_animation(animation)

func attack(behitMinion: Node) -> void:
	self.add_animation(CardAnimation.AttackAnimation.new(self, behitMinion))

# 受到伤害
func take_damage(damage) -> void:
	self.minionInfo["health"] -= damage
	self.update_minionInfo()
	
# 增加身材
func add_info(attack, health) -> void:
	self.minionInfo["attack"] += attack
	self.minionInfo["health"] += health
	self.update_minionInfo()
	
# 检查是否死亡
func check_health() -> bool:
	if self.minionInfo["health"] <= 0:
		return true
	return false

# 死亡方法
func die() -> void:
	self.add_animation(CardAnimation.DieAnimation.new(self))

# 逻辑方法
func hover() -> void:
	# 悬停时：展示随从牌内容
	# 先从数据库中拿到该牌的信息
	var originMinionInfo = MinionInfo.get_minion_by_id(GameManager.allMinionInfo, self.minionInfo["id"])
	originMinionNode = GameManager.originMinionTemplate.instantiate()
	self.add_child(originMinionNode)
	originMinionNode.global_position = self.global_position + Vector2(250, 0)
	originMinionNode.scale = Vector2(1.5, 1.5)
	originMinionNode.set_minionInfo(originMinionInfo)
	originMinionNode.use_minionInfo()
	originMinionNode.z_index = 100
	
func is_idle() -> bool:
	if self.moveState == MOVESTATE.IDLE:
		if self.animationQueueManager.is_idle():
			return true
	return false

func update_minionInfo() -> void:
	self.attackLabel.text = str(self.minionInfo["attack"])
	self.healthLabel.text = str(self.minionInfo["health"])

func is_in_buy_region() -> bool:
	return GameManager.is_in_region(GameManager.shopScene.buyRegionNode, self)
	
func is_in_desk_region() -> bool:
	return GameManager.is_in_region(GameManager.shopScene.deskRegionNode, self)
	
func is_in_sell_region() -> bool:
	return GameManager.is_in_region(GameManager.shopScene.sellRegionNode, self)

func _on_button_button_down() -> void:
	if belongState == BELONGSTATE.FIGHT: # 战斗状态避免拖拽
		return
	is_entered = false # 点击后不能查看卡牌信息
	self.set_move_drag()
	
func _on_button_button_up() -> void:
	match belongState:
		BELONGSTATE.SHOP:
			if is_in_buy_region() == true:
				print("购买随从")
				if GameManager.shopScene.can_buy_minion():
					GameManager.shopScene.buy_minion()
					GameManager.shopScene.shopCardNode.remove_card(self)
					GameManager.shopScene.handCardNode.add_card(self)
				else:
					print("购买失败，金币不足")
			else:
				GameManager.shopScene.shopCardNode.resort_card(self)
		BELONGSTATE.HAND:
			if is_in_desk_region() == true:
				print("使用随从")
				GameManager.shopScene.handCardNode.remove_card(self)
				GameManager.shopScene.deskCardNode.add_card(self)
				GameManager.shopScene.deskCardNode.resort_card(self)
		BELONGSTATE.DESK:
			if is_in_sell_region() == true:
				self.add_animation(CardAnimation.SellAnimation.new())
				self.add_animation(CardAnimation.RemoveAnimation.new(self, GameManager.shopScene.deskCardNode))
			else:
				GameManager.shopScene.deskCardNode.resort_card(self)
	self.set_move_follow()
	
func _on_button_mouse_entered() -> void:
	is_entered = true
	hover_start_time = Time.get_ticks_msec()
	is_hovering = false
	
func _on_button_mouse_exited() -> void:
	if is_hovering == true:
		originMinionNode.queue_free()
	is_entered = false
	is_hovering = false
	
# 配置方法 
func get_cardInfo() -> Dictionary:
	return self.minionInfo
	
func get_id() -> int:
	return self.minionInfo["id"]

func set_cardInfo(cardInfo: Dictionary) -> void:
	self.minionInfo = cardInfo

func set_minionInfo(minionInfo: Dictionary) -> void:
	self.minionInfo = minionInfo

func use_minionInfo() -> void:
	self.attackLabel.text = str(self.minionInfo["attack"])
	self.healthLabel.text = str(self.minionInfo["health"])
	self.minionSprite.texture = load(self.minionInfo["sprite_path"])
	
func use_minionInfo_level() -> void:
	self.levelSprite.texture = GameManager.levelSpriteTemplate[self.minionInfo["level"]]
	self.levelSprite.scale = GameManager.levelSpriteScale[self.minionInfo["level"]]

func get_attack() -> int:
	return self.minionInfo["attack"]

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
