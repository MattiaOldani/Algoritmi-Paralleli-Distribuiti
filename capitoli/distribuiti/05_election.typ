// Setup

#import "../alias.typ": *

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


// Capitolo

= Election

Il problema *election* vuole rompere la simmetria: dobbiamo individuare una entità tra tanta autonome e omogenee che diventi *leader*, rendendo le altre *follower*.

#lemma([Risultato di impossibilità])[
  È impossibile individuare deterministicamente un leader sotto le restrizioni R.
]

#proof()[
  Idea della dimostrazione: siano $x,y in E$ due entità omogenee inizializzate nello stesso modo e nello stesso stato. Essendo identiche, eseguono anche lo stesso algoritmo, trovandosi poi in uno stato finale uguale. Ma allora non ho trovato un leader.
]

#lemma([Risultato di possibilità])[
  Sotto le restrizioni RI l'entità di partenza diventa subito leader, ma il problema è risolto dall'esterno e non dal sistema.
]

Aggiungiamo una nuova restrizione, la *initial distinct values*, denotata con *ID*. Se aggiunta alle restrizione R otteniamo le restrizioni *IR*. Questa restrizione aggiunge un campo $id(x)$ ad ogni entità.

Abbiamo possibili *strategie* di soluzione:
- *elect minimum*: trova l'entità con $id(x)$ minimo la rende leader;
- *elect minimum initiator*: trova l'entità initiator con $id(x)$ minimo e la rende leader.

Risolveremo questo problema in una *topologia ring*, ovvero ad *anello*. In questa topologia le entità sono disposte ad anello, ovvero abbiamo $A = (x_0, dots, x_(n-1))$ con una connessione tra $x_(n-1)$ e $x_0$. Il numero di archi e il numero di entità sono uguali in questo caso.

Aggiungiamo un'ulteriore restrizione, ovvero che ogni entità sa di essere in un ring.

Infine, da ora chiameremo OTHER la quantità $N(x) - sender$.

== Prima versione

Una prima versione di protocollo per questo problema (_elect minimum_) è il protocollo *all the way*. I messaggi viaggiano intorno all'anello, inoltrati dalle varie entità in una direzione prestabilita. I messaggi mandati, per ora, sono nella forma (select, $id(x)$).

Quando una entità $x$ riceve un messaggio $E$ dall'entità $y$ inoltra $E$ all'entità successiva, assieme ad un messaggio $E'$ con $id(x)$ al posto di $id(y)$.

Con questo continuo inoltro di messaggi, ogni entità $x$ vede il valore $id(y)$ di ogni entità $y$ e può così calcolarne il minimo.

Quando facciamo terminare ogni entità? Una prima idea è fermare $x$ quando si riceve un messaggio $E$ con il proprio $id(x)$. Siamo sicuri di aver finito? Rispondiamo:
- *SI*: se supponiamo la restrizione *message ordering* (_prelevo FIFO_), ma noi non ce l'abbiamo;
- *solo se ne ha visti* $bold(n)$ *diversi*: se supponiamo che le entità siano a conoscenza della dimensione dell'anello, ma noi non ce l'abbiamo;
- *NO*: giusto, dobbiamo riempire in maniera opportuna i messaggi per far terminare correttamente le altre entità.

Quello che aggiungiamo al messaggio è un *contatore* che, partendo da $1$, viene continuamente incrementato ogni volta che una entità inoltra il messaggio. Quando il messaggio ritorna all'entità che ha generato il messaggio, essa saprà esattamente la dimensione della rete poiché contenuta dentro il contatore. Grazie a questa informazione, ora l'entità sa se può fermarsi e calcolare il minimo oppure aspettare ancora qualche messaggio mancante.

Vediamo gli *stati* utilizzati da questo protocollo:
- $S = {"asleep", "awake", "leader", "follower"}$;
- $sinit = {"asleep"}$;
- $sterm = {"leader", "follower"}$.

#align(center)[
  #pseudocode-list(title: [*Asleep*])[
    + Se riceve impulso spontaneo
      - $"initialize"()$
      - become awake
    + Se riceve (elect, value, counter)
      - $"initialize"()$
      - $send(("elect", "value", "counter" + 1))$ to OTHER
      - $min = min(min, "value")$
      - count = count + $1$
      - become awake
  ]
]

#align(center)[
  #pseudocode-list(title: [*Awake*])[
    + Se riceve (elect, value, counter)
      - if value $eq.not id(x)$
        - $send(("elect", "value", "counter" + 1))$ to OTHER
        - $min = min(min, "value")$
        - count = count + $1$
        - if know == true
          - $"check"()$
      - else
        - size = counter
        - know = true
        - $"check"()$
  ]
]

#align(center)[
  #pseudocode-list(title: [*Procedura initialize*])[
    + count = 0
    + size = 1
    + know = false
    + $send(("elect", id(x), 1))$ to RIGHT
    + $min = id(x)$
  ]
]

#align(center)[
  #pseudocode-list(title: [*Procedura check*])[
    + if count == size
      + if $min == id(x)$
        + become leader
      + else
        + become follower
  ]
]

Il *numero di messaggi* che vengono inviati con questo protocollo è $ M["all-the-way" slash "IR" union "RING"] = n^2 . $

== Seconda versione

Questa prima versione è troppo costosa, quindi passiamo al piano due: scegliamo elect minimum initiator come politica di ricerca. In questo caso, solo gli iniziatori spediscono un proprio messaggio $E$, tutte le altre entità inoltrano e basta. Quando gli initiator hanno finito il calcolo del leader, mandano un messaggio di fine a tutti gli altri. aggiungendo quindi $n$ messaggi finali.

Il *numero di messaggi* diventa ora $n k + n$, con $k$ numero di initiator, mentre il *tempo* è $lt.eq 3n - 1$, che si raggiunge quando $2$ initiator si attivano in momenti diversi.
