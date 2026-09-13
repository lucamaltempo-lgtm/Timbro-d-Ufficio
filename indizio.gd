extends Control

# Nomi di riserva, usati solo per testare questa scena da sola nell'editor.
@export var giocatori: Array[String] = ["Giocatore 1", "Giocatore 2", "Giocatore 3", "Giocatore 4"]

var indice_corrente: int = 0

# I nodi sono annidati dentro il pannello "Documento" (l'aspetto da foglio
# d'ufficio della schermata): vedi indizio.tscn.
@onready var lista_indizi: VBoxContainer = get_node("Documento/ScrollContainerIndizi/ListaIndizi")
@onready var contenitore_nascosto: Control = get_node("Documento/ContenitoreNascosto")
@onready var label_passaggio: Label = get_node("Documento/ContenitoreNascosto/LabelPassaggio")
@onready var bottone_mostra: Button = get_node("Documento/ContenitoreNascosto/BottoneMostra")
@onready var contenitore_rivelato: Control = get_node("Documento/ContenitoreRivelato")
@onready var label_parola: Label = get_node("Documento/ContenitoreRivelato/LabelParola")
@onready var campo_indizio: LineEdit = get_node("Documento/ContenitoreRivelato/CampoIndizio")
@onready var label_avviso: Label = get_node("Documento/ContenitoreRivelato/LabelAvviso")
@onready var bottone_conferma: Button = get_node("Documento/ContenitoreRivelato/BottoneConferma")

func _ready() -> void:
	print("Script indizio partito")
	if not GameState.giocatori.is_empty():
		giocatori = GameState.giocatori

	bottone_mostra.pressed.connect(_on_mostra_premuto)
	campo_indizio.text_changed.connect(_on_testo_indizio_cambiato)
	bottone_conferma.pressed.connect(_on_conferma_premuto)

	_aggiorna_lista_indizi()
	_mostra_turno_corrente()

# Schermata "passa il dispositivo": nasconde la parola segreta (o il messaggio
# di bluff per l'infiltrato) finché il giocatore di turno non conferma di
# essere pronto premendo "Mostra". Gli indizi già dati restano sempre visibili.
func _mostra_turno_corrente() -> void:
	if indice_corrente >= giocatori.size():
		get_tree().change_scene_to_file("res://discussione.tscn")
		return

	var giocatore_corrente = giocatori[indice_corrente]
	label_passaggio.text = "Passa il dispositivo a " + giocatore_corrente + ".\nQuando sei pronto/a, premi \"Mostra\"."
	contenitore_rivelato.visible = false
	contenitore_nascosto.visible = true

func _on_mostra_premuto() -> void:
	var giocatore_corrente = giocatori[indice_corrente]
	if giocatore_corrente == GameState.infiltrato:
		label_parola.text = "Non conosci la parola segreta: bluffa!"
	else:
		label_parola.text = "La parola segreta è: " + GameState.parola_segreta

	campo_indizio.text = ""
	campo_indizio.placeholder_text = "Scrivi il tuo indizio..."
	label_avviso.visible = false
	contenitore_nascosto.visible = false
	contenitore_rivelato.visible = true

# Nasconde l'avviso appena il giocatore modifica il testo: dovrà comunque
# premere di nuovo Conferma per far ricontrollare il nuovo testo.
func _on_testo_indizio_cambiato(_nuovo_testo: String) -> void:
	label_avviso.visible = false

func _on_conferma_premuto() -> void:
	var indizio = campo_indizio.text.strip_edges()
	if indizio.is_empty():
		print("Indizio vuoto, inserisci un testo prima di confermare")
		return

	var parola_vietata = Moderazione.trova_parola_vietata(indizio)
	if not parola_vietata.is_empty():
		label_avviso.text = "Testo non consentito: rimuovi la parola \"" + parola_vietata + "\" prima di confermare."
		label_avviso.visible = true
		print("Indizio bloccato dalla moderazione, parola vietata: ", parola_vietata)
		return

	var giocatore_corrente = giocatori[indice_corrente]
	GameState.indizi[giocatore_corrente] = indizio
	print("Indizio di ", giocatore_corrente, ": ", indizio)

	_aggiorna_lista_indizi()
	indice_corrente += 1
	_mostra_turno_corrente()

# Elenco pubblico degli indizi dati finora, sempre visibile (resta sullo
# schermo anche mentre il dispositivo passa al giocatore successivo).
func _aggiorna_lista_indizi() -> void:
	for figlio in lista_indizi.get_children():
		figlio.queue_free()

	for nome_giocatore in giocatori:
		if not GameState.indizi.has(nome_giocatore):
			continue
		var riga = Label.new()
		riga.text = "• " + nome_giocatore + ": " + GameState.indizi[nome_giocatore]
		riga.autowrap_mode = TextServer.AUTOWRAP_WORD
		riga.add_theme_color_override("font_color", TemaUfficio.COLORE_INCHIOSTRO)
		lista_indizi.add_child(riga)
