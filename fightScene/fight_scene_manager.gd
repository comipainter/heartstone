extends Control
class_name FightSceneManager

@export var enemyNode: Node
@export var playerNode: Node
@export var minionsNode: Node

enum FIGHTSCENESTATE{PREPARE, FIGHT}
var fightSceneState = FIGHTSCENESTATE.PREPARE

func _ready() -> void:
	GameManager.fightScene = self
	enemyNode.generate_card()
	playerNode.generate_card()
	
func _process(delta: float) -> void:
	match fightSceneState:
		FIGHTSCENESTATE.PREPARE:
			if enemyNode.is_all_idle() and playerNode.is_all_idle():
				fightSceneState = FIGHTSCENESTATE.FIGHT
				start_fight()
				
func start_fight() -> void:
	# 决定哪方先攻击
	var player_enemy_list = ["player", "enemy"]
	var curr = player_enemy_list[randi()%2]
	while true:
		# 先检查是否有一方随从全部退场
		if playerNode.is_all_dead() or enemyNode.is_all_dead():
			print("对战结束")
			break
		match curr:
			"player":
				# 当前玩家方随从先攻击
				var behitMinion = enemyNode.get_behit_minion()
				await playerNode.attack(behitMinion)
				curr = "enemy"
			"enemy":
				# 当前敌方随从先攻击
				var behitMinion = playerNode.get_behit_minion()
				await enemyNode.attack(behitMinion)
				curr = "player"
	
