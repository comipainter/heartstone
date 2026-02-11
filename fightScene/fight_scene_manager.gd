extends Control
class_name FightSceneManager

@export var enemyNode: Node
@export var playerNode: Node
@export var cardsNode: Node

enum FIGHTSCENESTATE{PREPARE, ATTACK, ATTACKING, END}
var fightSceneState = FIGHTSCENESTATE.PREPARE

# 决定哪方先攻击
var player_enemy_list = ["player", "enemy"]
var curr = player_enemy_list[randi()%2]

func _ready() -> void:
	GameManager.fightScene = self
	
	await get_tree().process_frame
	
	enemyNode.generate_cards()
	playerNode.generate_cards()
	
func _process(delta: float) -> void:
	match fightSceneState:
		FIGHTSCENESTATE.PREPARE:
			if enemyNode.is_idle() and playerNode.is_idle():
				fightSceneState = FIGHTSCENESTATE.ATTACK
		FIGHTSCENESTATE.ATTACK:
			# 先检查是否有一方随从全部退场
			if playerNode.is_all_dead():
				fightSceneState = FIGHTSCENESTATE.END
				print("对战结束, 敌方胜利")
				GameManager.end_fight()
			elif enemyNode.is_all_dead():
				fightSceneState = FIGHTSCENESTATE.END
				print("对战结束, 玩家胜利")
				GameManager.end_fight()
			else:
				fightSceneState = FIGHTSCENESTATE.ATTACKING
				match curr:
					"player":
						# 当前玩家方随从先攻击
						var behitMinion = enemyNode.get_behit_minion()
						playerNode.attack(behitMinion)
						curr = "enemy"
					"enemy":
						# 当前敌方随从先攻击
						var behitMinion = playerNode.get_behit_minion()
						enemyNode.attack(behitMinion)
						curr = "player"
		FIGHTSCENESTATE.ATTACKING:
			# 全部攻击动画完毕，则允许下次攻击
			if playerNode.is_idle() and enemyNode.is_idle():
				fightSceneState = FIGHTSCENESTATE.ATTACK
