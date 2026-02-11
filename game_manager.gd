extends Control

# 场景相关
enum SCENE{MAIN_MENU, LEVEL_SCENE, SHOP_SCENE, FIGHT_SCENE}
var sceneDict: Dictionary = {
	SCENE.MAIN_MENU: "res://mainMenuScene/main_menu.tscn",
	SCENE.LEVEL_SCENE: "res://levelScene/level_scene.tscn",
	SCENE.SHOP_SCENE: "res://shopScene/shop_scene.tscn",
	SCENE.FIGHT_SCENE: "res://fightScene/fight_scene.tscn"
}
var currScene = SCENE.MAIN_MENU
func change_scene(target_scene: SCENE):
	get_tree().change_scene_to_file(sceneDict.get(target_scene))
	currScene = target_scene

# 数据相关
const minionInfoPath = "res://assets/data/minionInfo/minionInfo.csv"
const magicInfoPath = "res://assets/data/magicInfo/magicInfo.csv"
var allMinionInfo = MinionInfo.load_allMinionInfo_from_csv(minionInfoPath)
var allMagicInfo = MagicInfo.load_allMagicInfo_from_csv(magicInfoPath)

# 玩家相关
var startCoin: int
var startCoinLimit: int
var coinRest: int
var coinLimit: int
var handCardInfoList = []
var deskCardInfoList = []

# 商店相关
var shopCardNum = 5
var shopLevelCost = [5,5,5,5,5]
var shopLevel = 1

# 卡牌相关
var minionTemplate = preload("res://minion/minion.tscn")
var magicTemplate = preload("res://magic/magic.tscn")
var originMinionTemplate = preload("res://minion/origin_minion.tscn")
var levelSpriteTemplate = [
	null,
	preload("res://assets/image/level/1.png"),
	preload("res://assets/image/level/2.png"),
	preload("res://assets/image/level/3.png"),
	preload("res://assets/image/level/4.png"),
	preload("res://assets/image/level/5.png"),
	preload("res://assets/image/level/6.png")
]
var levelSpriteScale = [
	null,
	Vector2(0.113, 0.113),
	Vector2(0.075, 0.076),
	Vector2(0.073, 0.082),
	Vector2(0.076, 0.078),
	Vector2(0.087, 0.078),
	Vector2(0.079, 0.076)
]
enum CARDTYPE{MINION, MAGIC}

# 关卡相关
enum LEVELTYPE{SHOP, FIGHT}
var levelType_map = [LEVELTYPE.SHOP, LEVELTYPE.FIGHT]
@export var level_num = 5 # 初始关卡数量
var levelType_list = []
var currLevelIndex: int

# 场景管理器相关
var shopScene: ShopSceneManager
var fightScene: FightSceneManager

# 游戏阶段管理器
enum GAMESTATE{START, MENU, MENUING, LEVEL, LEVELING, SHOP, SHOPPING, FIGHT, FIGHTING}
var gameState = GAMESTATE.MENU

func _process(delta: float) -> void:
	match gameState:
		GAMESTATE.MENU:
			gameState = GAMESTATE.MENUING
			self.change_scene(SCENE.MAIN_MENU)
		GAMESTATE.LEVEL:
			gameState = GAMESTATE.LEVELING
			self.change_scene(SCENE.LEVEL_SCENE)
		GAMESTATE.SHOP:
			gameState = GAMESTATE.SHOPPING
			self.change_scene(SCENE.SHOP_SCENE)
		GAMESTATE.FIGHT:
			gameState = GAMESTATE.FIGHTING
			self.change_scene(SCENE.FIGHT_SCENE)

# 逻辑方法
func end_menu() -> void:
	if gameState == GAMESTATE.MENUING:
		# 第一次进入关卡界面，需要初始化关卡列表
		#for i in range(level_num):
			#levelType_list.append(levelType_map[randi()%2])
		levelType_list.append(LEVELTYPE.SHOP)
		levelType_list.append(LEVELTYPE.FIGHT)
		levelType_list.append(LEVELTYPE.SHOP)
		#levelType_list.append(LEVELTYPE.SHOP)
		
		currLevelIndex = 0
		gameState = GAMESTATE.LEVEL

func end_level(levelType: LEVELTYPE) -> void:
	if gameState == GAMESTATE.LEVELING:
		if levelType == LEVELTYPE.FIGHT:
			gameState = GAMESTATE.FIGHT
		elif levelType == LEVELTYPE.SHOP:
			# 先设置好金币
			self.startCoin = 10
			self.startCoinLimit = 10
			coinRest = startCoin
			coinLimit = startCoinLimit
			gameState = GAMESTATE.SHOP

func end_shop(handCardInfoList: Array, deskCardInfoList: Array) -> void:
	if gameState == GAMESTATE.SHOPPING:
		currLevelIndex += 1
		self.handCardInfoList = handCardInfoList
		self.deskCardInfoList = deskCardInfoList
		gameState = GAMESTATE.LEVEL
		
func end_fight() -> void:
	if gameState == GAMESTATE.FIGHTING:
		currLevelIndex += 1
		gameState = GAMESTATE.LEVEL

# 静态方法
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
