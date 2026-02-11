extends Control

@export var initMinionNum: int
@onready var handCardNode = $HandCard
@onready var deskCardNode = $DeskCard

enum FIGHTSTATE{IDLE, ATTACK, ATTACKING, DIE, DYING, FOLLOW, FOLLOWING}
var fightState = FIGHTSTATE.IDLE

var behitMinion: Node

func generate_cards() -> void:
	var deskCardInfoList = []
	for i in range(initMinionNum):
		var randomMinionInfo = MinionInfo.choose_random_minion(GameManager.allMinionInfo)
		deskCardInfoList.append(randomMinionInfo)
	deskCardNode.generate_cards(deskCardInfoList)

func is_all_dead() -> bool:
	return deskCardNode.is_all_dead()
	
func follow() -> void:
	deskCardNode.follow()

func get_behit_minion() -> Node:
	return deskCardNode.get_behit_minion()

func is_idle() -> bool:
	if fightState == FIGHTSTATE.IDLE:
		return true
	return false

func is_all_idle() -> bool:
	if deskCardNode.is_all_idle():
		if handCardNode.is_all_idle():
			return true
	return false
	
func _process(delta: float) -> void:
	match fightState:
		FIGHTSTATE.ATTACK:
			fightState = FIGHTSTATE.ATTACKING
			# 从在场随从列表中选择最左侧的随从
			var leftMinion = deskCardNode.get_left_minion()
			# 触发最左侧随从攻击
			leftMinion.attack(behitMinion)
		FIGHTSTATE.ATTACKING: # 等待攻击动画完成
			if is_all_idle():
				fightState = FIGHTSTATE.DIE
		FIGHTSTATE.DIE:
			fightState = FIGHTSTATE.DYING
			deskCardNode.remove_die_minion()
			GameManager.fightScene.playerNode.deskCardNode.remove_die_minion()
		FIGHTSTATE.DYING:
			if is_all_idle():
				fightState = FIGHTSTATE.FOLLOW
		FIGHTSTATE.FOLLOW:
			fightState = FIGHTSTATE.FOLLOWING
			deskCardNode.follow()
			handCardNode.follow()
		FIGHTSTATE.FOLLOWING:
			if is_all_idle():
				fightState = FIGHTSTATE.IDLE

func attack(behitMinion: Node) -> void:
	self.behitMinion = behitMinion
	fightState = FIGHTSTATE.ATTACK
