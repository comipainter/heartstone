class_name MinionInfo

static func load_allMinionInfo_from_csv(path) -> Dictionary:
	var data = {}
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 2:
			var key = values[0]
			var row_dict = {}
			for i in range(0, headers.size()):
				# 如果headers[i]=="attack"/"health"则转换数字类型
				if headers[i] == "attack" or headers[i] == "health" or headers[i] == "level" or  headers[i] == "id":
					row_dict[headers[i]] = int(values[i]) if values[i].is_valid_int() else 0
				else:
					row_dict[headers[i]] = values[i]
			row_dict["type"] = "minion"
			row_dict["sprite_path"] = str("res://assets/image/minion/") + str(row_dict["id"]) + ".png"
			data[key] = row_dict
	file.close()
	return data


# 从其中随机选出一个随从的信息
static func choose_random_minion(minionInfo: Dictionary) -> Dictionary:
	var random_key = minionInfo.keys().pick_random()
	return minionInfo[random_key].duplicate()

# 从固定本数以下随机选出一个随从
static func choose_random_minion_under_level(minionInfo: Dictionary, level: int) -> Dictionary:
	var valid_keys: Array = []
	for key in minionInfo.keys():
		var minion = minionInfo[key]
		if minion["level"] <= level:
			valid_keys.append(key)
	if valid_keys.is_empty():
		push_error("No minions found at level %d" % level)
		return {}
	var random_key = valid_keys.pick_random()
	return minionInfo[random_key].duplicate()	

# 从固定本数中随机选出一个随从
static func choose_random_minion_in_level(minionInfo: Dictionary, level: int) -> Dictionary:
	var valid_keys: Array = []
	for key in minionInfo.keys():
		var minion = minionInfo[key]
		if minion["level"] == level:
			valid_keys.append(key)
	if valid_keys.is_empty():
		push_error("No minions found at level %d" % level)
		return {}
	var random_key = valid_keys.pick_random()
	return minionInfo[random_key].duplicate()

# 查询id随从
static func get_minion_by_id(minionInfo: Dictionary, id: int) -> Dictionary:
	for key in minionInfo.keys():
		var minion = minionInfo[key]
		if  minion["id"] == id:
			return minion.duplicate()
	push_error("Minion with id %d not found" % id)
	return {}
