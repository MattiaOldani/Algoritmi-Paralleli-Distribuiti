#import "alias.typ": *

#import "@preview/lovelace:0.3.0": pseudocode-list

#let settings = (
  line-numbering: "1:",
  stroke: 1pt + blue,
  hooks: 0.2em,
  booktabs: true,
  booktabs-stroke: 2pt + blue,
)

#let pseudocode-list = pseudocode-list.with(..settings)

#import "@local/typst-theorems:1.0.0": *
#show: thmrules.with(qed-symbol: $square.filled$)


= Lezione 23

== Election

Rompere la simmetria

Individuare una entità specifica tra tante autonome e omogenee. Tale è leader e le altre sono follower. Applicazioni: per certi lavori serve una unità centrale che diventi coordinatrice per le altre entità.

Risultato di impossibilità

#lemma()[
  Impossibile deterministicamente individuare un leader sotto le restrizioni R
]

#proof()[
  Idea della prova: siano $x,t in E$ omogenee. Esse sono nello stato e inizializzate nello stesso modo. Eseguono stesso algoritmo e sono ancora in simmetria. Ma allora non ho trovato un leader.
]

Risultato di possibilità

#lemma()[
  Sotto RI la starting entità diventa subito leader, il problema però è risolto dall'esterno e non dal sistema
]

Nuova restrizione: initial distinct values (ID), con IR notazione R union {ID}, ovvero ho id(x) = nome di x o valore di x (si confonde)

Strategia di soluzione:
- elect minimum:
  - trova id(x) minimo e fai x leader
  - $forall y eq.not x in E quad y$ diventa follower
- elect minimum initiator:
  - trova id(x) minimo tra le sole entità initiator ed eleggi x leader
  - same secondo punto

Primo risolviamo in una topologia ring, ad anello

Topologia ring: le entità sono dispose ad anello, ovvero ho $A = (x_0, dots, x_(n-1))$ e questo ha $m = n$

Aggiungiamo una restrizione, ovvero ogni entità x sa di essere in un ring

Chiameremo per ora N(x)-sender come OTHER, perché ho solo un altro vicino se tolgo il sender

Protocollo All the Way

I messaggi viaggiano intorno all'anello, inoltrati dalle entità nella stessa direzione. Messaggi sono ("elect", id(x), ...)

Quando x riceve E da y:
- inoltra E
- inoltra E' con id(x) al posto di id(y)

Questi verso OTHER

Ogni entità x vede id(y) forall y eq.not x in E e può calcolare il minimo

Quando facciamo terminare le entità?

Risposta parziale: una volta che x riceve un msg E con il proprio id(x) sa che E ha fatto il giro e quindi non lo inoltra più

Può terminare?
- si: se supponiamo message ordering (prelevo sui link secondo FIFO, ma noi non ce l'abbiamo)
- solo se ne ha visti n diversi: se si suppone che le entità siano a conoscenza della dimensione (ma noi non ce l'abbiamo)
- no: giusto, dobbiamo riempire in maniera opportuna i msg E per far terminare correttamente le altre entità (un contatore)

Come usare il counter su E = (elect, id(x), counter)
- inizio ho counter = 1 per x
- ogni altra entità y diversa da x che inoltra E somma 1 a counter
- quando E ritorna a X, il counter sarà uguale a n = abs(A)
- se x ha ricevuto n diversi id può terminare
- altrimenti aspetta, riceve altri messaggi e li inoltra, controlla per verificare se è arriva a n id diversi

Allora
- stati {asleep, awake, leader, follower}
- Sinit = {asleep}
- Sterm = {leader, follower}

Asleep
- spontaneo
  - initialize
  - become awake
- ricevono (elect, value, counter)
  - initialize
  - send (elect, value, counter + 1) to other
  - min = Min{min, value}
  - count = count + 1
  - become awake

Procedura initialize
- count = 0
- size = 1
- know = false
- send(elect, id(x), size) to right
- min = id(x)

Awake
- ricevo (elect, value, counter)
  - if value diverso id(x) then
    - send (elect, value, counter + 1) to other
    - min = Min{min, value}
    - count = count + 1
    - if know = true then check
  - else
    - size = counter
    - know = true
    - check

Procedura CHECK
- if count == size then
  - if min = id(x) then
    - become leader
  - else
    - become follower

Complessità
- M[All the way / IR union Ring] = n^2

Troppo costoso, vediamo versione due

Solo gli initiator generano E, mentre le altre inoltrano e basta

Problema di terminazione: da parte delle entità non initiator. Quando gli initiator hanno finito il calcolo del leader mandano messaggio di fine altri += n messaggi di fine

Complessità:
- M[Min] = nk + n dove k sono gli initiator
- T[Min] lt.eq 3n - 1 perché vanno in parallelo, per il tempo consideriamo caso peggiore, ovvero solo 2 initiator si attivano (n per il ciclo del primo, n per il secondo, n per il check). Lo raggiungiamo con 2 bro che si svegliano in momenti diversi
