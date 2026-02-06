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
				if headers[i] == "attack" or headers[i] == "health":
					row_dict[headers[i]] = int(values[i]) if values[i].is_valid_int() else 0
				else:
					row_dict[headers[i]] = values[i]
			data[key] = row_dict
	file.close()
	return data


# 从其中随机选出一个随从的信息
static func choose_random_minion(minionInfo: Dictionary) -> Dictionary:
	var minionInfo_keys = minionInfo.keys()
	var random_key = minionInfo_keys[randi() % minionInfo_keys.size()]
	return minionInfo[random_key]
	
