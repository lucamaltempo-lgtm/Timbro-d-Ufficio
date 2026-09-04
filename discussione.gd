extends Control

@onready var bottone_continua: Button = get_node("BottoneContinua")
@onready var timer_discussione: Timer = get_node("TimerDiscussione")
@onready var label_countdown: Label = get_node("LabelCountdown")

func _ready() -> void:
	print("Script discussione partito")
	bottone_continua.pressed.connect(_on_continua_premuto)
	timer_discussione.timeout.connect(_on_timer_timeout)
	_aggiorna_countdown()

func _process(_delta: float) -> void:
	_aggiorna_countdown()

func _aggiorna_countdown() -> void:
	var secondi_rimanenti = int(ceil(timer_discussione.time_left))
	label_countdown.text = "Tempo rimasto: " + str(secondi_rimanenti) + "s"

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
