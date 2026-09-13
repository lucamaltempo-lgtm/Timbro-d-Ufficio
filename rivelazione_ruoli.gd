extends Control

# Nomi di riserva, usati solo per testare questa scena da sola nell'editor.
@export var giocatori: Array[String] = ["Giocatore 1", "Giocatore 2", "Giocatore 3", "Giocatore 4"]

var indice_corrente: int = 0

# I nodi sono annidati dentro il pannello "Documento" (l'aspetto da foglio
# d'ufficio della schermata): vedi rivelazione_ruoli.tscn.
@onready var contenitore_nascosto: Control = get_node("Documento/ContenitoreNascosto")
@onready var label_passaggio: Label = get_node("Documento/ContenitoreNascosto/LabelPassaggio")
@onready var bottone_mostra: Button = get_node("Documento/ContenitoreNascosto/BottoneMostra")
@onready var contenitore_ruolo: Control = get_node("Documento/ContenitoreRuolo")
@onready var label_ruolo: Label = get_node("Documento/ContenitoreRuolo/LabelRuolo")
@onready var bottone_continua: Button = get_node("Documento/ContenitoreRuolo/BottoneContinua")

func _ready() -> void:
	print("Script rivelazione ruoli partito")
	if not GameState.giocatori.is_empty():
		giocatori = GameState.giocatori

	bottone_mostra.pressed.connect(_on_mostra_premuto)
	bottone_continua.pressed.connect(_on_continua_premuto)
	_mostra_turno_corrente()

# Schermata "passa il dispositivo": nasconde il ruolo finché il giocatore di
# turno non conferma di essere pronto premendo "Mostra il ruolo".
func _mostra_turno_corrente() -> void:
	if indice_corrente >= giocatori.size():
		get_tree().change_scene_to_file("res://assegnazione_timbri.tscn")
		return

	var giocatore_corrente = giocatori[indice_corrente]
	label_passaggio.text = "Passa il dispositivo a " + giocatore_corrente + ".\nQuando sei pronto/a, premi \"Mostra il ruolo\"."
	contenitore_ruolo.visible = false
	contenitore_nascosto.visible = true

func _on_mostra_premuto() -> void:
	var giocatore_corrente = giocatori[indice_corrente]
	label_ruolo.text = _testo_ruolo(giocatore_corrente)
	contenitore_nascosto.visible = false
	contenitore_ruolo.visible = true

# Testo del ruolo del giocatore indicato. Il Complice non ha azioni diverse
# dall'Innocente durante il gioco: l'unica informazione in più è sapere chi
# è l'infiltrato, da tenere segreta.
func _testo_ruolo(nome_giocatore: String) -> String:
	if nome_giocatore == GameState.infiltrato:
		return "Sei L'INFILTRATO.\n\nNon farti scoprire durante la votazione."
	elif nome_giocatore == GameState.complice:
		return "Sei il COMPLICE dell'infiltrato.\n\nL'infiltrato è: " + GameState.infiltrato + ".\n\nComportati in tutto e per tutto come un Innocente: nessuno deve sospettare di te."
	else:
		return "Sei un INNOCENTE.\n\nCerca di scoprire chi è l'infiltrato."

func _on_continua_premuto() -> void:
	contenitore_ruolo.visible = false
	indice_corrente += 1
	_mostra_turno_corrente()
