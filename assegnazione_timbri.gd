extends Control

# Nomi di riserva, usati solo per testare questa scena da sola nell'editor.
@export var giocatori: Array[String] = ["Giocatore 1", "Giocatore 2", "Giocatore 3", "Giocatore 4"]

var indice_corrente: int = 0
var giudizi: Dictionary = {}

# I nodi sono annidati dentro il pannello "Documento" (l'aspetto da foglio
# d'ufficio della schermata): vedi assegnazione_timbri.tscn.
@onready var label_giocatore: Label = get_node("Documento/LabelGiocatore")
@onready var campo_giudizio: LineEdit = get_node("Documento/CampoGiudizio")
@onready var bottone_conferma: Button = get_node("Documento/BottoneConferma")
@onready var label_avviso: Label = get_node("Documento/LabelAvviso")

func _ready() -> void:
	print("Script assegnazione timbri partito")
	if not GameState.giocatori.is_empty():
		giocatori = GameState.giocatori
	# GameState.infiltrato è disponibile per la logica di gioco ma non va
	# mostrato a schermo: l'infiltrato deve restare segreto.
	bottone_conferma.pressed.connect(_on_conferma_premuto)
	campo_giudizio.text_changed.connect(_on_testo_giudizio_cambiato)
	_mostra_giocatore_corrente()

func _mostra_giocatore_corrente() -> void:
	if indice_corrente >= giocatori.size():
		print("Giudizi raccolti: ", giudizi)
		GameState.giudizi = giudizi
		get_tree().change_scene_to_file("res://riepilogo_giudizi.tscn")
		return

	label_giocatore.text = giocatori[indice_corrente]
	campo_giudizio.text = ""
	campo_giudizio.placeholder_text = "Scrivi il tuo giudizio..."
	label_avviso.visible = false

# Nasconde l'avviso appena il giocatore modifica il testo: dovrà comunque
# premere di nuovo Conferma per far ricontrollare il nuovo testo.
func _on_testo_giudizio_cambiato(_nuovo_testo: String) -> void:
	label_avviso.visible = false

func _on_conferma_premuto() -> void:
	if indice_corrente >= giocatori.size():
		return

	var giudizio = campo_giudizio.text.strip_edges()
	if giudizio.is_empty():
		print("Giudizio vuoto, inserisci un testo prima di confermare")
		return

	var parola_vietata = Moderazione.trova_parola_vietata(giudizio)
	if not parola_vietata.is_empty():
		label_avviso.text = "Testo non consentito: rimuovi la parola \"" + parola_vietata + "\" prima di confermare."
		label_avviso.visible = true
		print("Giudizio bloccato dalla moderazione, parola vietata: ", parola_vietata)
		return

	var nome_giocatore = giocatori[indice_corrente]
	giudizi[nome_giocatore] = giudizio
	print("Timbro assegnato a ", nome_giocatore, ": ", giudizio)

	indice_corrente += 1
	_mostra_giocatore_corrente()
