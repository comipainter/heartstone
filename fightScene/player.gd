extends Control

@onready var handCardNode = $HandCard
@onready var deskCardNode = $DeskCard

func generate_cards() -> void:
	handCardNode.generate_cards(GameManager.handCardInfoList.duplicate(true))
	deskCardNode.generate_cards(GameManager.deskCardInfoList.duplicate(true))

func is_all_dead() -> bool:
	return deskCardNode.is_all_dead()
	
func follow() -> void:
	deskCardNode.follow()

func get_behit_minion() -> Node:
	return deskCardNode.get_behit_minion()

func is_all_idle() -> bool:
	if deskCardNode.is_all_idle():
		if handCardNode.is_all_idle():
			return true
	return false
	
func attack(behitMinion: Node) -> void:
	# 从在场随从列表中选择最左侧的随从
	var leftMinion = deskCardNode.get_left_minion()
	# 触发最左侧随从的攻击逻辑
	await leftMinion.attack(behitMinion)
	
	# 检查双方随从是否死亡，并且将死亡方法加入列表，在列表中并行死亡方法
	var minion_die_tasks = []
	if leftMinion.check_health():
		deskCardNode.remove_minion(leftMinion)
		minion_die_tasks.append(leftMinion.die())
	if behitMinion.check_health():
		GameManager.fightScene.enemyNode.deskCardNode.remove_minion(behitMinion)
		minion_die_tasks.append(behitMinion.die())
	for task in minion_die_tasks:
		await task
