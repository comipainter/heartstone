class_name CardAnimation

func execute() -> void:
	# 子类重写，返回一个可 await 的信号或协程
	pass

class AttackAnimation extends CardAnimation:
	var attackMinion: Node
	var behitMinion: Node
	func _init(attackMinion: Node, behitMinion: Node):
		self.attackMinion = attackMinion
		self.behitMinion = behitMinion
	func execute() -> void:
		print("执行攻击动画")
		var tween = attackMinion.create_tween()
	
		var original_pos = attackMinion.global_position
		var direction = (behitMinion.global_position - original_pos).normalized()
		var attack_offset = direction * 50

		# 蓄力后向前突进
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(attackMinion, "global_position", behitMinion.global_position - attack_offset, 1)
		
		# 短暂停顿
		tween.tween_callback(
			func():
				attackMinion.add_animation(CardAnimation.GetDamage.new(attackMinion))
				behitMinion.add_animation(CardAnimation.GetDamage.new(behitMinion))
		).set_delay(0.3)
		
		# 加速回到原位
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(attackMinion, "global_position", attackMinion.follow_target.global_position, 0.5)
		await tween.finished
		
		# 完成数值计算
		attackMinion.take_damage(behitMinion.get_attack())
		behitMinion.take_damage(attackMinion.get_attack())

class GetDamage extends CardAnimation:
	var minion: Node
	func _init(minion: Node):
		self.minion = minion
	func execute() -> void:
		print("执行受击动画")
		# 记录原始状态
		var original_rotation = minion.rotation_degrees
		var original_scale = minion.scale

		# 创建 Tween
		var tween = minion.create_tween()
		tween.set_parallel(false)  # 顺序执行

		# 定义旋转偏移序列（相对于原始角度）
		var rotation_offsets = [-20 , +20, -10, 0]
		for offset in rotation_offsets:
			tween.tween_property(minion, "rotation_degrees", original_rotation + offset, 0.1)

		# 定义缩放序列（相对于原始缩放）
		var scale_multipliers = [0.9, 1.1, 1.0]
		for mult in scale_multipliers:
			tween.tween_property(minion, "scale", original_scale * mult, 0.1)
		await tween.finished

class DieAnimation extends CardAnimation:
	var minion: Node
	func _init(minion: Node):
		self.minion = minion
	func execute() -> void:
		print("执行死亡动画")
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(minion, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
		await tween.finished
		
class SellAnimation extends CardAnimation:
	func execute() -> void:
		print("执行出售动画")
		GameManager.shopScene.sell_minion()
		
class RemoveAnimation extends CardAnimation:
	var minion: Node
	var node: Node
	func _init(minion: Node, node: Node):
		self.minion = minion
		self.node = node
	func execute() -> void:
		print("执行移除动画")
		node.remove_card(minion)
		minion.queue_free()

class DuoJinJianJiang extends CardAnimation:
	var minion: Node
	func _init(minion: Node):
		self.minion = minion
	func execute() -> void:
		print("执行夺金健将动画")
		var original_scale = minion.scale  # 保存原始缩放
		var enlarged_scale = original_scale * 1.5  # 放大 1.5 倍
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", enlarged_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "scale", original_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(minion, "modulate:a", 0.7, 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_IN)
		await tween.finished
		
		# 开始数值计算
		minion.add_info(1, 1)
		
class BaiZhuanDutu extends CardAnimation:
	func execute() -> void:
		print("执行白赚赌徒动画")
		# 开始数值计算
		GameManager.shopScene.coin_add(2)
		GameManager.shopScene.update_coin()
