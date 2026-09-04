extends Button

func _ready() -> void:
	print("Script partito")
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Bottone premuto")
	var giocatori = get_node("../VBoxContainer").get_children()
	var infiltrato = giocatori[randi() % giocatori.size()]
	# L'infiltrato resta segreto: non viene mostrato a schermo, solo salvato
	# in GameState per la logica di gioco nella schermata successiva.
	GameState.infiltrato = infiltrato.text
	get_tree().change_scene_to_file("res://assegnazione_timbri.tscn")
