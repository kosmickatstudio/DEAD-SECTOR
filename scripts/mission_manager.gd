class_name DeadSectorMissionManager
extends Node

const CAMPAIGN_PATH := "res://data/campaign.json"
var campaign: Dictionary = {}
var current_mission := 1

func _ready() -> void:
	_load_campaign()
	var save := DeadSectorSave.load_save()
	current_mission = int(save.get("mission",1))

func _load_campaign() -> void:
	var file := FileAccess.open(CAMPAIGN_PATH,FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			campaign = parsed

func get_mission(id:int) -> Dictionary:
	for chapter in campaign.get("chapters",[]):
		for mission in chapter.get("missions",[]):
			if int(mission.get("id",0)) == id:
				return mission
	return {}

func complete_current(evidence_found:int) -> void:
	DeadSectorSave.set_progress(current_mission + 1,evidence_found)
	current_mission += 1
