extends Node
class_name AnimationQueueManager

var animation_queue: Array = []

var is_playing: bool = false

func is_idle() -> bool:
	return !is_playing

func add_animation(animation: CardAnimation) -> void:
	animation_queue.append(animation)
	
func play_next() -> void:
	if animation_queue.is_empty():
		is_playing = false
		return
	var current_animation = animation_queue.pop_front()
	await current_animation.execute()
	# 递归播放下一个（或用 while 循环）
	#await get_tree().process_frame  # 避免栈溢出
	play_next()

func play() -> void:
	if not is_playing:
		if not animation_queue.is_empty():
			is_playing = true
			self.play_next()
