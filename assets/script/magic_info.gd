class_name MagicInfo

static func load_allMagicInfo_from_csv(path) -> Dictionary:
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
				# 如果headers[i]=="cost""则转换数字类型
				if headers[i] == "cost" or headers[i] == "level" or headers[i] == "id":
					row_dict[headers[i]] = int(values[i]) if values[i].is_valid_int() else 0
				else:
					row_dict[headers[i]] = values[i]
			row_dict["type"] = "magic"
			data[key] = row_dict
	file.close()
	return data


# 从其中随机选出一个法术信息
static func choose_random_magic(magicInfo: Dictionary) -> Dictionary:
	var random_key = magicInfo.keys().pick_random()
	return magicInfo[random_key].duplicate()
	
# 从固定本数以下随机选出一个法术
static func choose_random_magic_under_level(magicInfo: Dictionary, level: int) -> Dictionary:
	var valid_keys: Array = []
	for key in magicInfo.keys():
		var magic = magicInfo[key]
		if magic["level"] <= level:
			valid_keys.append(key)
	if valid_keys.is_empty():
		push_error("No minions found at level %d" % level)
		return {}
	var random_key = valid_keys.pick_random()
	return magicInfo[random_key].duplicate()	
	
