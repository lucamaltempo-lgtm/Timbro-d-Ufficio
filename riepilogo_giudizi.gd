extends Control

@onready var lista_giudizi: VBoxContainer = get_node("ScrollContainer/ListaGiudizi")
@onready var bottone_lobby: Button = get_node("BottoneLobby")

func _ready() -> void:
	print("Script riepilogo giudizi partito")
	bottone_lobby.pressed.connect(_on_lobby_premuto)
	_popola_riepilogo()

func _popola_riepilogo() -> void:
	for figlio in lista_giudizi.get_children():
		figlio.queue_free()

	for nome_giocatore in GameState.giudizi.keys():
		var riga = Label.new()
		riga.text = nome_giocatore + ": " + GameState.giudizi[nome_giocatore]
		lista_giudizi.add_child(riga)

func _on_lobby_premuto() -> void:
	print("Ritorno alla lobby")
	get_tree().change_scene_to_file("res://sch_princ.tscn")
