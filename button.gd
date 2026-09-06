extends Button

func _ready() -> void:
	print("Script partito")
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Bottone premuto")
	var giocatori = get_node("../VBoxContainer").get_children()
	var nomi_giocatori: Array[String] = []
	for giocatore in giocatori:
		nomi_giocatori.append(giocatore.text.strip_edges())

	var infiltrato = giocatori[randi() % giocatori.size()]
	# L'infiltrato resta segreto: non viene mostrato a schermo, solo salvato
	# in GameState per la logica di gioco nella schermata successiva.
	GameState.infiltrato = infiltrato.text.strip_edges()
	GameState.giocatori = nomi_giocatori
	# Nuova partita: azzera i gettoni azione e i voti extra della partita precedente.
	GameState.gettoni_usati = {}
	GameState.voti_extra = {}
	get_tree().change_scene_to_file("res://assegnazione_timbri.tscn")
