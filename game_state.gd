extends Node

# Singleton (autoload) usato per passare dati tra le scene.
var giocatori: Array[String] = []
var infiltrato: String = ""
var giudizi: Dictionary = {}

# Gettoni azione usati durante la discussione: nome giocatore -> { "depistaggio": bool, "verifica": bool }
var gettoni_usati: Dictionary = {}
# Voti extra segreti aggiunti col gettone Depistaggio: nome giocatore votato -> quanti voti extra
var voti_extra: Dictionary = {}
