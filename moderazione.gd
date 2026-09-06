extends Node

# Singleton (autoload) per la moderazione base dei testi liberi (es. i
# giudizi). Per aggiungere una nuova lingua basta inserire una nuova voce
# nel dizionario PAROLE_VIETATE con il codice lingua (es. "en") e la sua
# lista di parole vietate, senza toccare il resto del modulo o le schermate
# che lo usano.
const PAROLE_VIETATE: Dictionary = {
	"it": [
		"stronzo", "stronza", "stronzi", "stronze",
		"coglione", "cogliona", "coglioni",
		"idiota", "idioti", "idiote",
		"cretino", "cretina", "cretini", "cretine",
		"deficiente", "deficienti",
		"imbecille", "imbecilli",
		"merda", "merdoso", "merdosa",
		"bastardo", "bastarda", "bastardi", "bastarde",
		"puttana", "puttane",
		"troia", "troie",
		"vaffanculo",
		"cazzo", "cazzata", "cazzate", "cazzone", "cazzoni",
		"porco", "porca", "porci", "porche",
		"stupido", "stupida", "stupidi", "stupide",
		"scemo", "scema", "scemi", "sceme",
		"minchia", "minchione", "minchiona",
		"pirla",
		"fesso", "fessa", "fessi", "fesse",
		"sfigato", "sfigata", "sfigati", "sfigate",
		"schifoso", "schifosa", "schifosi", "schifose",
		"verme", "vermi",
		"maiale", "maiala", "maiali",
		"zoccola", "zoccole",
		"disgraziato", "disgraziata", "disgraziati", "disgraziate",
		"pezzente", "pezzenti",
		"lercio", "lercia", "lerci", "lerce",
		"rincoglionito", "rincoglionita", "rincoglioniti", "rincoglionite",
		"ritardato", "ritardata", "ritardati", "ritardate",
		"handicappato", "handicappata", "handicappati", "handicappate",
	],
}

# Lingua usata per il controllo. In futuro potrà essere impostata in base
# alla lingua dell'interfaccia invece di essere fissa.
var lingua: String = "it"

# Ritorna la prima parola vietata trovata nel testo (confronto per parole
# intere, non per sottostringa), oppure stringa vuota se il testo è pulito.
func trova_parola_vietata(testo: String) -> String:
	var lista_parole: Array = PAROLE_VIETATE.get(lingua, [])
	if lista_parole.is_empty():
		return ""

	var parole_nel_testo = _estrai_parole(testo.to_lower())
	for parola_vietata in lista_parole:
		if parole_nel_testo.has(parola_vietata):
			return parola_vietata

	return ""

func testo_e_accettabile(testo: String) -> bool:
	return trova_parola_vietata(testo).is_empty()

# Divide il testo in parole intere usando i confini Unicode, così una parola
# vietata dentro una parola più lunga (es. accenti, apostrofi) non genera
# falsi positivi né falsi negativi.
func _estrai_parole(testo: String) -> Array:
	var espressione = RegEx.new()
	espressione.compile("[\\p{L}]+")
	var parole: Array = []
	for corrispondenza in espressione.search_all(testo):
		parole.append(corrispondenza.get_string())
	return parole
