extends Node

# Singleton (autoload) con lo stile "documento d'ufficio" condiviso da tutte
# le schermate. I nodi statici nelle scene referenziano direttamente i file
# .tres in res://; questo modulo serve per applicare lo stesso stile ai
# controlli creati via codice (bottoni e campi testo generati a runtime),
# così l'aspetto resta identico ovunque senza duplicare gli stessi valori
# in ogni script.

const COLORE_INCHIOSTRO := Color(0.2, 0.17, 0.13)
const COLORE_INCHIOSTRO_DISABILITATO := Color(0.55, 0.5, 0.42)
const COLORE_TESTO_PRIMARIO := Color(0.96, 0.96, 0.95)

const STILE_BOTTONE_NORMALE = preload("res://stile_bottone_normale.tres")
const STILE_BOTTONE_HOVER = preload("res://stile_bottone_hover.tres")
const STILE_BOTTONE_PREMUTO = preload("res://stile_bottone_premuto.tres")
const STILE_BOTTONE_DISABILITATO = preload("res://stile_bottone_disabilitato.tres")

const STILE_BOTTONE_PRIMARIO_NORMALE = preload("res://stile_bottone_primario_normale.tres")
const STILE_BOTTONE_PRIMARIO_HOVER = preload("res://stile_bottone_primario_hover.tres")
const STILE_BOTTONE_PRIMARIO_PREMUTO = preload("res://stile_bottone_primario_premuto.tres")

const STILE_CAMPO_TESTO_NORMALE = preload("res://stile_campo_testo.tres")
const STILE_CAMPO_TESTO_FOCUS = preload("res://stile_campo_testo_focus.tres")

# Applica lo stile bottone "da ufficio" a un Button creato via codice.
# primario = true per l'azione principale della schermata (accento blu),
# false per le azioni secondarie (beige neutro), come nei bottoni statici.
func applica_stile_bottone(bottone: Button, primario: bool = false) -> void:
	if primario:
		bottone.add_theme_stylebox_override("normal", STILE_BOTTONE_PRIMARIO_NORMALE)
		bottone.add_theme_stylebox_override("hover", STILE_BOTTONE_PRIMARIO_HOVER)
		bottone.add_theme_stylebox_override("pressed", STILE_BOTTONE_PRIMARIO_PREMUTO)
		bottone.add_theme_color_override("font_color", COLORE_TESTO_PRIMARIO)
		bottone.add_theme_color_override("font_hover_color", COLORE_TESTO_PRIMARIO)
		bottone.add_theme_color_override("font_pressed_color", COLORE_TESTO_PRIMARIO)
	else:
		bottone.add_theme_stylebox_override("normal", STILE_BOTTONE_NORMALE)
		bottone.add_theme_stylebox_override("hover", STILE_BOTTONE_HOVER)
		bottone.add_theme_stylebox_override("pressed", STILE_BOTTONE_PREMUTO)
		bottone.add_theme_stylebox_override("disabled", STILE_BOTTONE_DISABILITATO)
		bottone.add_theme_color_override("font_color", COLORE_INCHIOSTRO)
		bottone.add_theme_color_override("font_disabled_color", COLORE_INCHIOSTRO_DISABILITATO)

# Applica lo stile campo testo "da modulo" a un LineEdit creato via codice.
func applica_stile_campo_testo(campo: LineEdit) -> void:
	campo.add_theme_stylebox_override("normal", STILE_CAMPO_TESTO_NORMALE)
	campo.add_theme_stylebox_override("focus", STILE_CAMPO_TESTO_FOCUS)
	campo.add_theme_color_override("font_color", COLORE_INCHIOSTRO)
	campo.add_theme_color_override("font_placeholder_color", COLORE_INCHIOSTRO_DISABILITATO)
