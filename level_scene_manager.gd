extends Control

@export var levelsNode: Control

@onready var line_2d: Line2D

var level_list = []
var level_icon_size = 112

@onready var fightTemplate = preload("res://levelScene/battle.tscn")
@onready var shopTemplate = preload("res://levelScene/shop.tscn")

func _ready() -> void:
	generate_levels()
	await get_tree().process_frame
	for i in range(len(self.level_list)):
		if i == 0:
			continue
		var pointStart = self.level_list[i-1].global_position
		var pointEnd = self.level_list[i].global_position
		var pointFrom = Vector2(pointStart.x + level_icon_size, pointStart.y + level_icon_size/2)
		var pointTo = Vector2(pointEnd.x, pointEnd.y + level_icon_size/2)
		add_line(pointFrom, pointTo)

func add_line(point1: Vector2, point2: Vector2) -> void:
	line_2d = Line2D.new()
	levelsNode.linesNode.add_child(line_2d)
	line_2d.width = 10  # 线的宽度
	line_2d.default_color = Color(0.244, 0.244, 0.244, 1.0)
	line_2d.closed = false  # 是否闭合（首尾相连）
	line_2d.antialiased = true  # 是否开启平滑抗锯齿
	line_2d.texture = null  # 无纹理（也可设置纹理实现纹理线）
	line_2d.points = [point1, point2]

func generate_levels() -> void:
	for levelType in GameManager.levelType_list:
		match levelType:
			GameManager.LEVELTYPE.FIGHT:
				var fightLevel = fightTemplate.instantiate()
				self.level_list.append(fightLevel)
				levelsNode.levelContainerNode.add_child(fightLevel)
			GameManager.LEVELTYPE.SHOP:
				var shopLevel = shopTemplate.instantiate()
				self.level_list.append(shopLevel)
				levelsNode.levelContainerNode.add_child(shopLevel)

func _on_end_button_button_up() -> void:
	GameManager.end_level(GameManager.levelType_list[GameManager.currLevelIndex])
