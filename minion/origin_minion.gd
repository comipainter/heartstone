extends Control
# 卡牌种类
var cardType = GameManager.CARDTYPE.MINION

# 节点信息
@onready var nameLabel = $Panel/NameLabel
@onready var raceLabel = $Panel/RaceLabel
@onready var attackLabel = $Panel/AttackLabel
@onready var healthLabel = $Panel/HealthLabel
@onready var descriptionLabel = $Panel/DescriptionLabel
@onready var levelSprite = $Panel/LevelSprite

var minionInfo: Dictionary

# 配置方法 
func get_cardInfo() -> Dictionary:
	return self.minionInfo

func set_cardInfo(cardInfo: Dictionary) -> void:
	self.minionInfo = cardInfo

func set_minionInfo(minionInfo: Dictionary) -> void:
	self.minionInfo = minionInfo

func use_minionInfo() -> void:
	self.nameLabel.text = self.minionInfo["minion_name"]
	self.raceLabel.text = self.minionInfo["race"]
	self.attackLabel.text = str(self.minionInfo["attack"])
	self.healthLabel.text = str(self.minionInfo["health"])
	self.descriptionLabel.text = self.minionInfo["description"]
	self.levelSprite.texture = GameManager.levelSpriteTemplate[self.minionInfo["level"]]
	self.levelSprite.scale = GameManager.levelSpriteScale[self.minionInfo["level"]]
	
