extends Control

# Nodi annidati dentro il pannello "Documento" (l'aspetto da foglio d'ufficio
# della schermata): vedi riepilogo_giudizi.tscn.
@onready var lista_giudizi: VBoxContainer = get_node("Documento/ScrollContainer/ListaGiudizi")
@onready var bottone_discussione: Button = get_node("Documento/BottoneDiscussione")
@onready var bottone_lobby: Button = get_node("Documento/BottoneLobby")

# Colore "inchiostro" usato per le righe del modulo, coerente col resto del
# documento finto.
const COLORE_INCHIOSTRO := Color(0.2, 0.17, 0.13)

func _ready() -> void:
	print("Script riepilogo giudizi partito")
	bottone_discussione.pressed.connect(_on_discussione_premuto)
	bottone_lobby.pressed.connect(_on_lobby_premuto)
	_popola_riepilogo()

func _popola_riepilogo() -> void:
	for figlio in lista_giudizi.get_children():
		figlio.queue_free()

	for nome_giocatore in GameState.giudizi.keys():
		var riga = Label.new()
		riga.text = "• " + nome_giocatore + ": " + GameState.giudizi[nome_giocatore]
		riga.autowrap_mode = TextServer.AUTOWRAP_WORD
		riga.add_theme_color_override("font_color", COLORE_INCHIOSTRO)
		riga.add_theme_font_size_override("font_size", 16)
		lista_giudizi.add_child(riga)

func _on_discussione_premuto() -> void:
	print("Vado alla discussione")
	get_tree().change_scene_to_file("res://discussione.tscn")

func _on_lobby_premuto() -> void:
	print("Ritorno alla lobby")
	get_tree().change_scene_to_file("res://sch_princ.tscn")
