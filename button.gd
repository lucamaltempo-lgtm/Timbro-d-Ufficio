extends Control

# Lobby: permette di aggiungere/rimuovere giocatori (min 3, max 10) prima di
# iniziare la partita. Ogni riga ha un nome modificabile e un bottone Rimuovi.

const GIOCATORI_INIZIALI := 4
const MIN_GIOCATORI := 3
const MAX_GIOCATORI := 10

# Parole semplici usate come parola segreta della fase Indizio. Note a tutti
# i giocatori tranne che all'infiltrato, che deve bluffare senza conoscerla.
const PAROLE_SEGRETE: Array[String] = [
	"PANE", "SOLE", "LIBRO", "GATTO", "CASA", "FIUME", "MELA", "TRENO",
	"SCUOLA", "MARE", "MONTAGNA", "FIORE", "STRADA", "FINESTRA", "CHIAVE",
	"OROLOGIO", "SEDIA", "ALBERO", "PONTE", "LUNA",
]

var righe_giocatori: Array[HBoxContainer] = []

# I nodi sono annidati dentro il pannello "Documento" (l'aspetto da foglio
# d'ufficio della schermata): vedi sch_princ.tscn.
@onready var lista_giocatori: VBoxContainer = get_node("Documento/ScrollContainer/ListaGiocatori")
@onready var bottone_aggiungi: Button = get_node("Documento/BottoneAggiungi")
@onready var bottone_inizio: Button = get_node("Documento/BottoneInizio")
@onready var label_conteggio: Label = get_node("Documento/LabelConteggio")

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
	TemaUfficio.applica_stile_campo_testo(campo_nome)
	riga.add_child(campo_nome)

	var bottone_rimuovi = Button.new()
	bottone_rimuovi.text = "Rimuovi"
	bottone_rimuovi.pressed.connect(_on_rimuovi_premuto.bind(riga))
	TemaUfficio.applica_stile_bottone(bottone_rimuovi)
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

	# L'infiltrato viene salvato in GameState per la logica di gioco; verrà
	# rivelato privatamente a ogni giocatore, uno alla volta, nella prossima
	# schermata (rivelazione_ruoli), mai mostrato a più persone insieme.
	var infiltrato = nomi_giocatori[randi() % nomi_giocatori.size()]
	GameState.infiltrato = infiltrato

	# Il Complice (0 o 1 a partita) conosce l'infiltrato ma gioca in tutto e
	# per tutto come un Innocente: nessuna azione visibile diversa durante il
	# gioco. La probabilità che ci sia cresce con il numero di giocatori, per
	# non sbilanciare troppo le partite piccole.
	var complice = ""
	if randf() < _probabilita_complice(nomi_giocatori.size()):
		var candidati_complice: Array[String] = nomi_giocatori.filter(
			func(nome): return nome != infiltrato
		)
		complice = candidati_complice[randi() % candidati_complice.size()]
	GameState.complice = complice

	# Parola segreta della fase Indizio: nota a tutti tranne che all'infiltrato.
	GameState.parola_segreta = PAROLE_SEGRETE[randi() % PAROLE_SEGRETE.size()]

	GameState.giocatori = nomi_giocatori
	# Nuova partita: azzera i gettoni azione, i voti extra e gli indizi della partita precedente.
	GameState.gettoni_usati = {}
	GameState.voti_extra = {}
	GameState.indizi = {}
	get_tree().change_scene_to_file("res://rivelazione_ruoli.tscn")

# Probabilità di assegnare il Complice in base al numero di giocatori: con
# gruppi piccoli (3-4) non compare mai, poi diventa via via più probabile.
func _probabilita_complice(numero_giocatori: int) -> float:
	if numero_giocatori <= 4:
		return 0.0
	elif numero_giocatori <= 6:
		return 1.0 / 3.0
	elif numero_giocatori <= 8:
		return 0.5
	else:
		return 2.0 / 3.0

# Evita nomi duplicati (romperebbero la logica a chiave-nome delle altre schermate).
func _rendi_nome_univoco(nome: String, nomi_esistenti: Array[String]) -> String:
	if not nomi_esistenti.has(nome):
		return nome

	var contatore = 2
	while nomi_esistenti.has(nome + " (" + str(contatore) + ")"):
		contatore += 1
	return nome + " (" + str(contatore) + ")"
