extends Control

# 节点信息
@onready var nameLabel = $Panel/NameLabel
@onready var raceLabel = $Panel/RaceLabel
@onready var attackLabel = $Panel/AttackLabel
@onready var healthLabel = $Panel/HealthLabel
@onready var descriptionLabel = $Panel/DescriptionLabel

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

# 随从战斗状态
enum FIGHTSTATE{IDLE, ATTACK, BEHIT, DEAD}
var fightState=FIGHTSTATE.IDLE

# 随从信息
var minionInfo: Dictionary

func _ready():
	set_process(true)
	use_minionInfo()

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
# 战斗方法
func is_die() -> bool:
	if fightState == FIGHTSTATE.DEAD:
		return true
	return false
	
func attack(target_minion) -> Signal:
	var tween = create_tween()
	
	var original_pos = follow_target.global_position
	var direction = (target_minion.global_position - original_pos).normalized()
	var attack_offset = direction * 50

	# 蓄力后向前突进
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", target_minion.global_position - attack_offset, 1)
	
	# 短暂停顿
	tween.tween_callback(
		func():
			self.take_damage(target_minion.get_damage())
			target_minion.take_damage(self.get_damage())
	).set_delay(0.3)
	
	# 加速回到原位
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", follow_target.global_position, 0.5)
	return tween.finished

# 受到伤害
func take_damage(damage) -> void:
	self.minionInfo["health"] -= damage
	self.update_minionInfo()
	await behit_animation()
	
# 检查是否死亡
func check_health() -> bool:
	if self.minionInfo["health"] <= 0:
		return true
	return false

func die() -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
	return tween.finished

func behit_animation() -> Signal:
	# 记录原始状态
	var original_rotation = rotation_degrees
	var original_scale = scale

	# 创建 Tween
	var tween = create_tween()
	tween.set_parallel(false)  # 顺序执行

	# 定义旋转偏移序列（相对于原始角度）
	var rotation_offsets = [-20 , +20, -10, 0]
	for offset in rotation_offsets:
		tween.tween_property(self, "rotation_degrees", original_rotation + offset, 0.1)

	# 定义缩放序列（相对于原始缩放）
	var scale_multipliers = [0.9, 1.1, 1.0]
	for mult in scale_multipliers:
		tween.tween_property(self, "scale", original_scale * mult, 0.1)

	# 返回完成信号
	return tween.finished

# 逻辑方法
func is_idle() -> bool:
	if self.moveState == MOVESTATE.IDLE:
		return true
	return false

func update_minionInfo() -> void:
	self.attackLabel.text = str(self.minionInfo["attack"])
	self.healthLabel.text = str(self.minionInfo["health"])

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
				print("购买卡牌")
				if GameManager.player.can_buy_minion():
					GameManager.player.buy_minion()
					GameManager.shopScene.shopCardNode.remove_card(self)
					GameManager.shopScene.handCardNode.add_card(self)
				else:
					print("购买失败，金币不足")
			else:
				GameManager.shopScene.shopCardNode.resort_card(self)
		BELONGSTATE.HAND:
			if is_in_desk_region() == true:
				print("使用卡牌")
				GameManager.shopScene.handCardNode.remove_card(self)
				GameManager.shopScene.deskCardNode.add_card(self)
				GameManager.shopScene.deskCardNode.resort_card(self)
		BELONGSTATE.DESK:
			GameManager.shopScene.deskCardNode.resort_card(self)
	self.set_move_follow()
	
# 配置方法
func set_minionInfo(minionInfo: Dictionary) -> void:
	self.minionInfo = minionInfo

func use_minionInfo() -> void:
	self.nameLabel.text = self.minionInfo["minion_name"]
	self.raceLabel.text = self.minionInfo["race"]
	self.attackLabel.text = str(self.minionInfo["attack"])
	self.healthLabel.text = str(self.minionInfo["health"])
	self.descriptionLabel.text = self.minionInfo["description"]
	
func get_damage() -> int:
	return self.minionInfo["attack"]

func set_follow_target(target: Node) -> void:
	follow_target = target

func get_follow_target() -> Node:
	return follow_target
	
func set_belong_none() -> void:
	belongState=BELONGSTATE.NONE

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
