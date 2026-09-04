extends Control

# Nomi di riserva, usati solo per testare questa scena da sola nell'editor.
@export var giocatori: Array[String] = ["Giocatore 1", "Giocatore 2", "Giocatore 3", "Giocatore 4"]

var indice_corrente: int = 0
var giudizi: Dictionary = {}

@onready var label_giocatore: Label = get_node("LabelGiocatore")
@onready var campo_giudizio: LineEdit = get_node("CampoGiudizio")
@onready var bottone_conferma: Button = get_node("BottoneConferma")

func _ready() -> void:
	print("Script assegnazione timbri partito")
	if not GameState.giocatori.is_empty():
		giocatori = GameState.giocatori
	# GameState.infiltrato è disponibile per la logica di gioco ma non va
	# mostrato a schermo: l'infiltrato deve restare segreto.
	bottone_conferma.pressed.connect(_on_conferma_premuto)
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

func _on_conferma_premuto() -> void:
	if indice_corrente >= giocatori.size():
		return

	var giudizio = campo_giudizio.text.strip_edges()
	if giudizio.is_empty():
		print("Giudizio vuoto, inserisci un testo prima di confermare")
		return

	var nome_giocatore = giocatori[indice_corrente]
	giudizi[nome_giocatore] = giudizio
	print("Timbro assegnato a ", nome_giocatore, ": ", giudizio)

	indice_corrente += 1
	_mostra_giocatore_corrente()
