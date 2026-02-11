extends Control

@export var linesNode: Control
@export var levelContainerNode: HBoxContainer

@export var separationSize: int

func _ready() -> void:
	levelContainerNode.add_theme_constant_override("separation", separationSize)
