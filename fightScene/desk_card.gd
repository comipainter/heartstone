extends Control

@export var separationSize: int
@export var minionStartPosition: Vector2
@onready var minionContainerNode = $ScrollContainer/MinionContainer

var minionTemplate = GameManager.minionTemplate
var magicTemplate = GameManager.magicTemplate
var minionList = []
var minionLiveList = []

func _ready() -> void:
	minionContainerNode.add_theme_constant_override("separation", separationSize)
	
func is_all_dead() -> bool:
	for minion in minionLiveList:
		if not minion.is_die():
			return false
	return true
	
func get_left_minion() -> Node:
	# 从在场随从列表中选择最左侧的随从
	var leftMinion = minionLiveList[0]
	for minion in minionLiveList:
		if (minion.global_position < leftMinion.global_position):
			leftMinion = minion
	return leftMinion
	
func get_behit_minion() -> Node:
	return minionLiveList[randi() % minionLiveList.size()]
	
func is_all_idle() -> bool:
	for minion in minionLiveList:
		if not minion.is_idle():
			return false
	return true
	
func follow() -> void:
	for minionInLiveList in minionLiveList:
		minionInLiveList.set_move_follow()
	
func generate_cards(minionInfoList: Array) -> void:
	for minionInfo in minionInfoList:
		# 再创建卡牌，使其跟随占位箱
		var minion = self.minionTemplate.instantiate()
		minion.set_minionInfo(minionInfo)
		GameManager.fightScene.cardsNode.add_child(minion)
		minion.global_position = minionStartPosition
		self.add_minion(minion)

func add_minion(minion: Node) -> void:
	# 先添加卡牌占位箱
	var minionBox = Control.new()
	minionContainerNode.add_child(minionBox)
	
	# 再使其跟随占位箱
	minion.set_follow_target(minionBox)
	minion.set_move_follow()
	minion.set_belong_fight()

	# 添加卡牌列表
	minionList.append(minion)
	minionLiveList.append(minion)
	
	# 使所有节点开始重新跟随
	follow()

func remove_minion(minion: Node) -> void:
	# 先删除卡牌占位箱
	var minionBox = minion.get_follow_target()
	minionContainerNode.remove_child(minionBox)
	minionBox.queue_free()
	
	minion.set_move_idle()
	minion.set_belong_none()
	# 从卡牌列表中删除
	minionList.erase(minion)
	minionLiveList.erase(minion)
	# 使剩余卡牌开始跟随
	follow()
