extends Control

# Nomi di riserva, usati solo per testare questa scena da sola nell'editor.
@export var giocatori: Array[String] = ["Giocatore 1", "Giocatore 2", "Giocatore 3", "Giocatore 4"]

var indice_corrente: int = 0
var voti: Dictionary = {}

@onready var contenitore_voto: Control = get_node("ContenitoreVoto")
@onready var label_giocatore: Label = get_node("ContenitoreVoto/LabelGiocatore")
@onready var lista_voto: VBoxContainer = get_node("ContenitoreVoto/ScrollContainer/ListaVoto")
@onready var contenitore_risultati: Control = get_node("ContenitoreRisultati")
@onready var label_risultato: Label = get_node("ContenitoreRisultati/LabelRisultato")
@onready var lista_voti_dettaglio: VBoxContainer = get_node("ContenitoreRisultati/ScrollContainerRisultati/ListaVotiDettaglio")
@onready var bottone_lobby: Button = get_node("ContenitoreRisultati/BottoneLobby")

func _ready() -> void:
	print("Script votazione partito")
	if not GameState.giocatori.is_empty():
		giocatori = GameState.giocatori

	for nome_giocatore in giocatori:
		# Il gettone Depistaggio, se usato durante la discussione, ha già
		# aggiunto voti extra segreti che partono qui inclusi nel conteggio.
		voti[nome_giocatore] = GameState.voti_extra.get(nome_giocatore, 0)

	bottone_lobby.pressed.connect(_on_lobby_premuto)
	_mostra_turno_corrente()

# Ogni giocatore vota a turno sullo stesso dispositivo: mostra il turno
# corrente finché tutti hanno votato, poi passa ai risultati.
func _mostra_turno_corrente() -> void:
	if indice_corrente >= giocatori.size():
		_mostra_risultati()
		return

	var votante = giocatori[indice_corrente]
	label_giocatore.text = "Tocca a " + votante + ": chi pensi sia l'infiltrato?"

	for figlio in lista_voto.get_children():
		figlio.queue_free()

	for nome_giocatore in giocatori:
		if nome_giocatore == votante:
			continue
		var bottone = Button.new()
		bottone.text = nome_giocatore
		bottone.pressed.connect(_on_voto_premuto.bind(nome_giocatore))
		lista_voto.add_child(bottone)

func _on_voto_premuto(nome_votato: String) -> void:
	print("Voto ricevuto per ", nome_votato)
	voti[nome_votato] += 1
	indice_corrente += 1
	_mostra_turno_corrente()

func _mostra_risultati() -> void:
	contenitore_voto.visible = false
	contenitore_risultati.visible = true

	for figlio in lista_voti_dettaglio.get_children():
		figlio.queue_free()

	var voti_massimi = 0
	for nome_giocatore in voti.keys():
		voti_massimi = max(voti_massimi, voti[nome_giocatore])

	var piu_votati: Array[String] = []
	for nome_giocatore in giocatori:
		var riga = Label.new()
		riga.text = nome_giocatore + ": " + str(voti[nome_giocatore]) + " voti"
		lista_voti_dettaglio.add_child(riga)
		if voti[nome_giocatore] == voti_massimi:
			piu_votati.append(nome_giocatore)

	var infiltrato_scoperto = GameState.infiltrato in piu_votati

	var testo = "Più votato/i: " + ", ".join(piu_votati) + "\n"
	testo += "L'infiltrato era: " + GameState.infiltrato + "\n"
	if infiltrato_scoperto:
		testo += "L'infiltrato è stato scoperto!\n"
		testo += "Vittoria degli altri giocatori!"
	else:
		testo += "L'infiltrato NON è stato scoperto!\n"
		testo += "Vittoria dell'infiltrato!"

	label_risultato.text = testo
	print(testo)

func _on_lobby_premuto() -> void:
	print("Ritorno alla lobby")
	get_tree().change_scene_to_file("res://sch_princ.tscn")
