extends Control

@onready var bottone_continua: Button = get_node("BottoneContinua")

func _ready() -> void:
	print("Script discussione partito")
	bottone_continua.pressed.connect(_on_continua_premuto)

func _on_continua_premuto() -> void:
	print("Discussione terminata, vado alla votazione")
	get_tree().change_scene_to_file("res://votazione.tscn")
