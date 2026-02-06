extends Control

@export var initMinionNum: int
@export var separationSize: int
@export var minionStartPosition: Vector2
@onready var minionContainerNode = $ScrollContainer/MinionContainer
@onready var minionTemplate = GameManager.minionTemplate

var minionList = []
var minionLiveList = []

func _ready() -> void:
	minionContainerNode.add_theme_constant_override("separation", separationSize)

func generate_card() -> void:
	for i in range(initMinionNum):
		# 先添加随从占位箱
		var minionBox = Control.new()
		minionContainerNode.add_child(minionBox)
		
		# 再创建随从，使其跟随占位箱
		var minion = minionTemplate.instantiate()
		minion.set_follow_target(minionBox)
		
		# 添加随从信息
		var randomMinionInfo = MinionInfo.choose_random_minion(GameManager.allMinionInfo)
		minion.set_minionInfo(randomMinionInfo)
		
		minion.set_move_follow()
		minion.set_belong_fight()
		GameManager.fightScene.minionsNode.add_child(minion)
		minion.global_position = minionStartPosition
		
		# 加入随从列表
		minionList.append(minion)
		minionLiveList.append(minion)

func is_all_dead() -> bool:
	for minion in minionList:
		if not minion.is_die():
			return false	
	return true
	
func attack(behitMinion: Node) -> void:
	# 从在场随从列表中选择最左侧的随从
	var leftMinion = minionLiveList[0]
	for minion in minionLiveList:
		if (minion.global_position < leftMinion.global_position):
			leftMinion = minion
	# 触发最左侧随从的攻击逻辑
	await leftMinion.attack(behitMinion)
	
func get_behit_minion() -> Node:
	return minionLiveList[randi() % minionLiveList.size()]
	
func is_all_idle() -> bool:
	for minion in minionList:
		if not minion.is_idle():
			return false	
	return true
