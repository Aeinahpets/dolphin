# GameManager.gd
extends Node

var current_part = 1
var unlocked_abilities = {
	"flip": true,
	"sonar": false,
	"stealth": false
}

func has_ability(ability_name: String) -> bool:
	return unlocked_abilities.get(ability_name, false)

func unlock_ability(ability_name: String):
	unlocked_abilities[ability_name] = true
