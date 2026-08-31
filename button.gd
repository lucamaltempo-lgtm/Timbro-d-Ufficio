extends Button

func _ready() -> void:
	print("Script partito")
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Bottone premuto")
	var giocatori = get_node("../VBoxContainer").get_children()
	var infiltrato = giocatori[randi() % giocatori.size()]
	get_node("../Label").text = "Infiltrato: " + infiltrato.text
