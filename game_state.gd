extends Node

# Singleton (autoload) usato per passare dati tra le scene.
var giocatori: Array[String] = []
var infiltrato: String = ""
# Ruolo opzionale (0 o 1 giocatore a partita): conosce chi è l'infiltrato fin
# dall'inizio ma gioca in tutto e per tutto come un Innocente. Stringa vuota
# se in questa partita non è stato assegnato a nessuno.
var complice: String = ""
var giudizi: Dictionary = {}

# Gettoni azione usati durante la discussione: nome giocatore -> { "depistaggio": bool, "verifica": bool }
var gettoni_usati: Dictionary = {}
# Voti extra segreti aggiunti col gettone Depistaggio: nome giocatore votato -> quanti voti extra
var voti_extra: Dictionary = {}
