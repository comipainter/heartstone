extends Control

# 场景相关
enum SCENE{MAIN_MENU, SHOP_SCENE, FIGHT_SCENE}
var sceneDict: Dictionary = {
	SCENE.MAIN_MENU: "res://mainMenuScene/main_menu.tscn",
	SCENE.SHOP_SCENE: "res://shopScene/shop_scene.tscn",
	SCENE.FIGHT_SCENE: "res://fightScene/fight_scene.tscn"
}
var currScene = SCENE.MAIN_MENU
func change_scene(target_scene: SCENE):
	get_tree().change_scene_to_file(sceneDict.get(target_scene))
	currScene = target_scene

# 数据相关
const minionInfoPath = "res://assets/data/minionInfo/minionInfo.csv"
var allMinionInfo = MinionInfo.load_allMinionInfo_from_csv(minionInfoPath)

# 玩家相关
var startCoin: int
var startCoinLimit: int
var player = Player.new()

# 卡牌相关
var minionTemplate = preload("res://minion/minion.tscn")

# 场景管理器相关
var shopScene: ShopSceneManager
var fightScene: FightSceneManager

# 逻辑方法
func start_game() -> void:
	self.startCoin = 5
	self.startCoinLimit = 5
	player.set_coinRest(startCoin)
	player.set_coinLimit(startCoinLimit)
	self.start_shop()
	
func start_shop() -> void:
	self.change_scene(SCENE.SHOP_SCENE)

func end_shop() -> void:
	self.change_scene(SCENE.FIGHT_SCENE)

# 数学方法
func is_in_region(regionNode: Node, judgeNode: Node) -> bool:
	var regionMinPosition = regionNode.global_position
	var regionMaxPosition = regionNode.global_position + regionNode.size
	var judgeMinPosition = judgeNode.global_position
	var judgeMaxPosition = judgeNode.global_position + judgeNode.size
	if regionMinPosition.x < judgeMinPosition.x:
		if regionMinPosition.y < judgeMinPosition.y:
			if regionMaxPosition.x > judgeMaxPosition.x:
				if regionMaxPosition.y > judgeMaxPosition.y:
					return true
	return false
	
