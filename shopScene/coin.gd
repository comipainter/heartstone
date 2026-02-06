extends Control

@export var coinLabelNode: Node

func set_coin(coinRest, coinLimit) -> void:
	coinLabelNode.text = str(coinRest) + " / " + str(coinLimit)
