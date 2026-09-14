class_name DeadSectorSave
extends Node

const PATH := "user://dead_sector_save.json"

static func load_save() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {"mission":1,"evidence":0,"weapons":{"pistol_level":1},"settings":{"vibration":true}}
	var file := FileAccess.open(PATH,FileAccess.READ)
	var text := file.get_as_text()
	var data = JSON.parse_string(text)
	return data if data is Dictionary else {"mission":1,"evidence":0}

static func write_save(data: Dictionary) -> void:
	var file := FileAccess.open(PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

static func set_progress(mission:int,evidence:int) -> void:
	var data := load_save()
	data["mission"] = mission
	data["evidence"] = evidence
	write_save(data)
