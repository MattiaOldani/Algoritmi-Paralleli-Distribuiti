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


= Lezione 01

== Introduzione

=== Definizione

Un *algoritmo* è una sequenza finita di istruzioni che non sono ambigue e che terminano, ovvero restituiscono un risultato. Gli *algoritmi sequenziali* avevano un solo esecutore, mentre gli algoritmi di questo corso utilizzano un *pool di esecutori*.

Le problematiche da risolvere negli algoritmi sequenziali si ripropongono anche qua, ovvero:
- *progettazione*: utilizzo di tecniche per la risoluzione, come _Divide et Impera_, _programmazione dinamica_ o _greedy_;
- *valutazione delle prestazioni*: complessità spaziale e temporale;
- *codifica*: implementare con opportuni linguaggi di programmazione i vari algoritmi presentati.

I programmi diventano quindi una _sequenza di righe_, ognuna delle quali contiene _una o più_ istruzioni.

=== Algoritmi paralleli

Un *algoritmo parallelo* è un algoritmo *sincrono* che risponde al motto _"una squadra in cui batte un solo cuore"_, ovvero si hanno più entità che obbediscono ad un clock centrale, che va a coordinare tutto il sistema.

Abbiamo la possibilità di condividere le risorse in due modi:
- memoria, formando le architetture:
  - *a memoria condivisa*, ovvero celle di memoria fisicamente condivisa;
  - *a memoria distribuita*, ovvero ogni entità salva parte dei risultati parziali sul proprio nodo;
- uso di opportuni collegamenti.

Qualche esempio di architettura parallela:
- *supercomputer*: cluster di processori con altissime prestazioni;
- *GPU*: usate in ambienti grafici, molto utili anche in ambito vettoriale;
- *processori multicore*;
- *circuiti integrati*: insieme di gate opportunamente connessi.

=== Algoritmi distribuiti

Un *algoritmo distribuito* è un algoritmo *asincrono* che risponde al motto _"ogni membro del pool è un mondo a parte"_, ovvero si hanno più entità che obbediscono al proprio clock personale. Abbiamo anche in questo caso dei collegamenti ma non dobbiamo supporre una memoria condivisa o qualche tipo di sincronizzazione, quindi dobbiamo utilizzare lo *scambio di messaggi*.

Qualche esempio di architettura distribuita:
- *reti di calcolatori*: internet;
- *reti mobili*: uso di diverse tipologie di connessione;
- *reti di sensori*: sistemi con limitate capacità computazionali che rispondono a messaggi _ack_, _recover_, _wake up_, eccetera.

=== Differenze

Vediamo un problema semplicissimo: _sommare quattro numeri A,B,C,D_.

#v(12pt)

#figure(
  image("assets/01_somma-numeri.svg", width: 50%),
)

#v(12pt)

Usiamo la primitiva `send(sorgente,destinazione)` per l'invio di messaggi.

Un approccio parallelo a questo problema è il seguente.

#align(center)[
  #pseudocode-list(title: [Somma di quattro numeri])[
    - *input*:
      - quattro numeri $A,B,C,D$
    + $send(1,2)$, $send(3,4)$
    + calcola $A+B$ e $C+D$
    + $send(2,4)$
    + calcola $(A+B) + (C+D)$
  ]
]

Un approccio distribuito invece non può seguire questo pseudocodice, perché le due send iniziali potrebbero avvenire in tempi diversi.

Notiamo come negli algoritmi paralleli ciò che conta è il *tempo*, mentre negli algoritmi distribuiti ciò che conta è il *coordinamento*.
