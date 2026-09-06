extends Control

# Nomi di riserva, usati solo per testare questa scena da sola nell'editor.
@export var giocatori: Array[String] = ["Giocatore 1", "Giocatore 2", "Giocatore 3", "Giocatore 4"]

var indice_corrente: int = 0
var azione_in_corso: String = ""  # "" | "depistaggio" | "verifica"

# I nodi sono annidati dentro il pannello "Documento" (l'aspetto da foglio
# d'ufficio della schermata): vedi discussione.tscn.
@onready var contenitore_gettoni: Control = get_node("Documento/ContenitoreGettoni")
@onready var label_giocatore_gettoni: Label = get_node("Documento/ContenitoreGettoni/LabelGiocatoreGettoni")
@onready var bottone_depistaggio: Button = get_node("Documento/ContenitoreGettoni/BottoneDepistaggio")
@onready var bottone_verifica: Button = get_node("Documento/ContenitoreGettoni/BottoneVerifica")
@onready var bottone_passa: Button = get_node("Documento/ContenitoreGettoni/BottonePassa")
@onready var contenitore_selezione_target: Control = get_node("Documento/ContenitoreGettoni/ContenitoreSelezioneTarget")
@onready var label_selezione_target: Label = get_node("Documento/ContenitoreGettoni/ContenitoreSelezioneTarget/LabelSelezioneTarget")
@onready var lista_target: VBoxContainer = get_node("Documento/ContenitoreGettoni/ContenitoreSelezioneTarget/ScrollContainerTarget/ListaTarget")
@onready var bottone_annulla_selezione: Button = get_node("Documento/ContenitoreGettoni/ContenitoreSelezioneTarget/BottoneAnnullaSelezione")
@onready var contenitore_risultato_segreto: Control = get_node("Documento/ContenitoreGettoni/ContenitoreRisultatoSegreto")
@onready var label_risultato_segreto: Label = get_node("Documento/ContenitoreGettoni/ContenitoreRisultatoSegreto/LabelRisultatoSegreto")
@onready var bottone_ok_prossimo: Button = get_node("Documento/ContenitoreGettoni/ContenitoreRisultatoSegreto/BottoneOkProssimo")

@onready var contenitore_discussione: Control = get_node("Documento/ContenitoreDiscussione")
@onready var bottone_continua: Button = get_node("Documento/ContenitoreDiscussione/BottoneContinua")
@onready var timer_discussione: Timer = get_node("Documento/ContenitoreDiscussione/TimerDiscussione")
@onready var label_countdown: Label = get_node("Documento/ContenitoreDiscussione/LabelCountdown")

func _ready() -> void:
	print("Script discussione partito")
	if not GameState.giocatori.is_empty():
		giocatori = GameState.giocatori

	bottone_depistaggio.pressed.connect(_on_depistaggio_premuto)
	bottone_verifica.pressed.connect(_on_verifica_premuto)
	bottone_passa.pressed.connect(_on_passa_premuto)
	bottone_annulla_selezione.pressed.connect(_on_annulla_selezione_premuto)
	bottone_ok_prossimo.pressed.connect(_on_ok_prossimo_premuto)
	bottone_continua.pressed.connect(_on_continua_premuto)
	timer_discussione.timeout.connect(_on_timer_timeout)

	_mostra_turno_gettoni()

func _process(_delta: float) -> void:
	if contenitore_discussione.visible:
		_aggiorna_countdown()

func _aggiorna_countdown() -> void:
	var secondi_rimanenti = int(ceil(timer_discussione.time_left))
	label_countdown.text = "Tempo rimasto: " + str(secondi_rimanenti) + "s"

# Fase a turni, prima della discussione: ogni giocatore, a turno e in segreto,
# può usare i suoi gettoni azione (una volta a partita ciascuno) o passare.
func _mostra_turno_gettoni() -> void:
	if indice_corrente >= giocatori.size():
		_mostra_fase_discussione()
		return

	contenitore_selezione_target.visible = false
	contenitore_risultato_segreto.visible = false
	contenitore_gettoni.visible = true
	_imposta_visibilita_scelte_gettoni(true)

	var giocatore_corrente = giocatori[indice_corrente]
	label_giocatore_gettoni.text = "Tocca a " + giocatore_corrente + ": usa un gettone azione in segreto o passa il turno."

	var usati: Dictionary = GameState.gettoni_usati.get(giocatore_corrente, {})
	bottone_depistaggio.disabled = usati.get("depistaggio", false)
	bottone_verifica.disabled = usati.get("verifica", false)

# La label e i 3 bottoni della scelta gettoni condividono lo spazio a schermo
# con la selezione target e il risultato segreto: vanno nascosti esplicitamente
# quando quegli altri pannelli sono visibili, altrimenti il testo vi si sovrappone.
func _imposta_visibilita_scelte_gettoni(visibile: bool) -> void:
	label_giocatore_gettoni.visible = visibile
	bottone_depistaggio.visible = visibile
	bottone_verifica.visible = visibile
	bottone_passa.visible = visibile

func _on_depistaggio_premuto() -> void:
	azione_in_corso = "depistaggio"
	_mostra_selezione_target("Scegli in segreto chi accusare: aggiungerai un voto extra contro di lui.")

func _on_verifica_premuto() -> void:
	azione_in_corso = "verifica"
	_mostra_selezione_target("Scegli in segreto chi vuoi verificare.")

func _mostra_selezione_target(testo: String) -> void:
	label_selezione_target.text = testo

	for figlio in lista_target.get_children():
		figlio.queue_free()

	var giocatore_corrente = giocatori[indice_corrente]
	for nome_giocatore in giocatori:
		if nome_giocatore == giocatore_corrente:
			continue
		var bottone = Button.new()
		bottone.text = nome_giocatore
		bottone.pressed.connect(_on_target_scelto.bind(nome_giocatore))
		TemaUfficio.applica_stile_bottone(bottone)
		lista_target.add_child(bottone)

	_imposta_visibilita_scelte_gettoni(false)
	contenitore_selezione_target.visible = true

func _on_annulla_selezione_premuto() -> void:
	azione_in_corso = ""
	contenitore_selezione_target.visible = false
	_imposta_visibilita_scelte_gettoni(true)

func _on_target_scelto(nome_target: String) -> void:
	var giocatore_corrente = giocatori[indice_corrente]
	if not GameState.gettoni_usati.has(giocatore_corrente):
		GameState.gettoni_usati[giocatore_corrente] = {}

	if azione_in_corso == "depistaggio":
		GameState.gettoni_usati[giocatore_corrente]["depistaggio"] = true
		GameState.voti_extra[nome_target] = GameState.voti_extra.get(nome_target, 0) + 1
		label_risultato_segreto.text = "Hai aggiunto in segreto un voto extra contro " + nome_target + "."
		print(giocatore_corrente, " ha usato Depistaggio contro ", nome_target)
	elif azione_in_corso == "verifica":
		GameState.gettoni_usati[giocatore_corrente]["verifica"] = true
		if nome_target == GameState.infiltrato:
			label_risultato_segreto.text = nome_target + " È L'INFILTRATO!"
		else:
			label_risultato_segreto.text = nome_target + " NON è l'infiltrato."
		print(giocatore_corrente, " ha usato Verifica su ", nome_target)

	azione_in_corso = ""
	contenitore_selezione_target.visible = false
	contenitore_risultato_segreto.visible = true

func _on_ok_prossimo_premuto() -> void:
	contenitore_risultato_segreto.visible = false
	indice_corrente += 1
	_mostra_turno_gettoni()

func _on_passa_premuto() -> void:
	indice_corrente += 1
	_mostra_turno_gettoni()

# Fase finale: discussione a voce con countdown condiviso, come prima.
func _mostra_fase_discussione() -> void:
	contenitore_gettoni.visible = false
	contenitore_discussione.visible = true
	timer_discussione.start()
	_aggiorna_countdown()

# Il tempo è scaduto: passa automaticamente alla votazione.
func _on_timer_timeout() -> void:
	print("Tempo scaduto, vado alla votazione")
	_vai_alla_votazione()

# Il bottone Continua permette di saltare l'attesa del timer.
func _on_continua_premuto() -> void:
	print("Discussione terminata, vado alla votazione")
	_vai_alla_votazione()

func _vai_alla_votazione() -> void:
	get_tree().change_scene_to_file("res://votazione.tscn")
