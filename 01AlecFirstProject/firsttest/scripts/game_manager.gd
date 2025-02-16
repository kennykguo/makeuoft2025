extends Node

var apples = 0

@onready var pomme_label: Label = $PommeLabel


func add_point():
	apples += 1
	pomme_label.text = "Pommes Collected: " + str(apples)
	
	
