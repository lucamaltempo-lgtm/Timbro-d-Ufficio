extends Control

# Lobby: permette di aggiungere/rimuovere giocatori (min 3, max 10) prima di
# iniziare la partita. Ogni riga ha un nome modificabile e un bottone Rimuovi.

const GIOCATORI_INIZIALI := 4
const MIN_GIOCATORI := 3
const MAX_GIOCATORI := 10

var righe_giocatori: Array[HBoxContainer] = []

@onready var lista_giocatori: VBoxContainer = get_node("ScrollContainer/ListaGiocatori")
@onready var bottone_aggiungi: Button = get_node("BottoneAggiungi")
@onready var bottone_inizio: Button = get_node("BottoneInizio")
@onready var label_conteggio: Label = get_node("LabelConteggio")

func _ready() -> void:
	print("Script lobby partito")
	bottone_aggiungi.pressed.connect(_on_aggiungi_premuto)
	bottone_inizio.pressed.connect(_on_inizio_premuto)

	for i in range(GIOCATORI_INIZIALI):
		_aggiungi_riga("Giocatore " + str(i + 1))

	_aggiorna_stato()

# Crea una riga con campo nome modificabile e bottone per rimuoverla.
func _aggiungi_riga(nome_predefinito: String) -> void:
	var riga = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 8)

	var campo_nome = LineEdit.new()
	campo_nome.text = nome_predefinito
	campo_nome.placeholder_text = "Nome giocatore"
	campo_nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(campo_nome)

	var bottone_rimuovi = Button.new()
	bottone_rimuovi.text = "Rimuovi"
	bottone_rimuovi.pressed.connect(_on_rimuovi_premuto.bind(riga))
	riga.add_child(bottone_rimuovi)

	lista_giocatori.add_child(riga)
	righe_giocatori.append(riga)

func _on_aggiungi_premuto() -> void:
	if righe_giocatori.size() >= MAX_GIOCATORI:
		return

	_aggiungi_riga("Giocatore " + str(righe_giocatori.size() + 1))
	_aggiorna_stato()

func _on_rimuovi_premuto(riga: HBoxContainer) -> void:
	if righe_giocatori.size() <= MIN_GIOCATORI:
		return

	righe_giocatori.erase(riga)
	riga.queue_free()
	_aggiorna_stato()

# Aggiorna il contatore e disabilita Aggiungi/Rimuovi ai limiti min/max.
func _aggiorna_stato() -> void:
	var numero_giocatori = righe_giocatori.size()
	label_conteggio.text = "Giocatori: %d/%d" % [numero_giocatori, MAX_GIOCATORI]
	bottone_aggiungi.disabled = numero_giocatori >= MAX_GIOCATORI

	for riga in righe_giocatori:
		var bottone_rimuovi: Button = riga.get_child(1)
		bottone_rimuovi.disabled = numero_giocatori <= MIN_GIOCATORI

func _on_inizio_premuto() -> void:
	print("Bottone premuto")
	var nomi_giocatori: Array[String] = []
	for riga in righe_giocatori:
		var campo_nome: LineEdit = riga.get_child(0)
		var nome = campo_nome.text.strip_edges()
		if nome.is_empty():
			nome = "Giocatore " + str(nomi_giocatori.size() + 1)
		nomi_giocatori.append(_rendi_nome_univoco(nome, nomi_giocatori))

	# L'infiltrato resta segreto: non viene mostrato a schermo, solo salvato
	# in GameState per la logica di gioco nella schermata successiva.
	var infiltrato = nomi_giocatori[randi() % nomi_giocatori.size()]
	GameState.infiltrato = infiltrato
	GameState.giocatori = nomi_giocatori
	# Nuova partita: azzera i gettoni azione e i voti extra della partita precedente.
	GameState.gettoni_usati = {}
	GameState.voti_extra = {}
	get_tree().change_scene_to_file("res://assegnazione_timbri.tscn")

# Evita nomi duplicati (romperebbero la logica a chiave-nome delle altre schermate).
func _rendi_nome_univoco(nome: String, nomi_esistenti: Array[String]) -> String:
	if not nomi_esistenti.has(nome):
		return nome

	var contatore = 2
	while nomi_esistenti.has(nome + " (" + str(contatore) + ")"):
		contatore += 1
	return nome + " (" + str(contatore) + ")"
