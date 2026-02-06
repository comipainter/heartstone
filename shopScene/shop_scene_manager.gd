extends Control
class_name ShopSceneManager

@export var handCardNode: Node
@export var deskCardNode: Node
@export var shopCardNode: Node
@export var buyRegionNode: Node
@export var deskRegionNode: Node
@export var cardsNode: Node
@export var coinLabelNode: Node

func _ready() -> void:
	GameManager.shopScene = self
	GameManager.player.start_shop()
	
func _on_end_button_button_up() -> void:
	GameManager.end_shop()
