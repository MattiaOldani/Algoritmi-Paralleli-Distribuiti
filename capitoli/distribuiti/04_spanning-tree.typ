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

= Spanning tree

Il problema dello *spanning tree* è molto comodo perché permette di ridurre un grafo completo ad uno molto più leggero che semplifica la complessità di comunicazione. Dobbiamo stare comunque attenti ai costi, soprattutto a quelli di costruzione dell'albero e a quelli a cui andremo incontro con questa nuova rappresentazione.

Il problema dello spanning tree ci richiede di costruire una *sotto-rete* tale che:
- ogni entità è presente;
- ogni entità è connessa;
- è priva di cicli.

Per risolvere questo problema dobbiamo dare un po' di conoscenza dell'albero alle entità.

Definiamo $treenx(x) subset.eq N(x)$ il sottoinsieme dei vicini di $x$ che partecipano all'albero e che sono collegati direttamente a $x$. Diciamo che un arco $(x,y)$ sta nell'insieme $link(treenx(x))$ se e solo se $y in treenx(x)$. Questo insieme è l'insieme degli archi uscenti da $x$ diretti nei nodi di $treenx(x)$.

Infine, definiamo Tree come $ union.big_(x in E) link(treenx(x)) . $

== Prima versione

Usando sempre le restrizioni RI, definiamo il protocollo *shout*.

La *radice* dell'albero è l'entità che inizierà il protocollo. Il protocollo fa quello che dice il suo nome: ogni entità chiederà ai suoi vicini se vogliono partecipare, con il loro arco, all'albero.

Vediamo i passi che segue questo protocollo:
- la radice $s$ spedisce $Q$ ai suoi vicini e attende le risposte;
- ogni entità $x$ diversa da $s$ che riceve $Q$:
  - per la prima volta risponde *SI* e invia $Q$ ai suoi vicini, mettendosi in attesa come ha fatto $s$;
  - per l'$n$-esima volta ($n gt.eq 2$) risponde *NO*;
- ogni entità memorizza il padre dal quale ha ricevuto $Q$ e tutti i figli che hanno risposto *SI*;
- una entità termina quando riceve tutte le risposte.

Abbiamo a disposizione i seguenti *stati*:
- $S = {"iniziatore", "inattivo", "attivo", "finito"}$;
- $sinit = {"iniziatore", "inattivo"}$;
- $sterm = {"finito"}$.

#align(center)[
  #pseudocode-list(title: [*Iniziatore*])[
    + Se riceve impulso spontaneo
      - root = true
      - counter = 0
      - $treenx(x) = emptyset.rev$
      - $send(Q)$ to $N(x)$
      - become attivo
  ]
]

#align(center)[
  #pseudocode-list(title: [*Inattivo*])[
    + Se riceve $Q$
      - root = false
      - parent = sender
      - counter = 1
      - $treenx(x) = sender$
      - $send("SI")$ to sender
      - if counter $== abs(N(x))$
        - become finito
      - else
        - $send(Q)$ to $N(x) - sender$
        - become attivo
  ]
]

#align(center)[
  #pseudocode-list(title: [*Attivo*])[
    + Se riceve $Q$
      - $send("NO")$ to sender
    + Se riceve SI
      - $treenx(x) = treenx(x) union {sender}$
      - counter = counter + $1$
      - if counter $== abs(N(x))$
        - become finito
    + Se riceve NO
      - counter = counter + $1$
      - if counter $== abs(N(x))$
        - become finito
  ]
]

Questo protocollo è corretto:
- *terminazione*: ogni entità entra nello stato terminale quando ha ricevuto tutte le risposte;
- *albero*: tutte le entità sono presenti e connesse per flooding + SI al primo $Q$ che ricevono, e non ho dei cicli perché rispondo SI una e una sola volta (la radice unica che dice sempre NO).

Il *numero di messaggio* inviati è $ M["shout"] = underbracket(2 M["flooding"], Q + "risposta") = 2[2m - (n-1)] approx 4m $ mentre il *tempo* è $ T["shout"] = T["flooding"] + underbracket(quad 1 quad, "ultimo" Q) lt.eq d + 1 . $

== Seconda versione

Una seconda versione di shout, che chiameremo *shout++*,cerca di eliminare qualche messaggio, perché come tempo ci siamo con il lower bound.

Questa versione cancella i NO. La decisione dietro a questa pazza idea è perché i NO vengono inviati al sender di una $Q$ quando il nodo ha già ricevuto un $Q$. Teniamo quindi tutti i SI e interpretiamo i $Q$ doppioni come se fossero dei NO.

Il nuovo *numero di messaggi* è $2m$, perché mandiamo su uno stesso link:
- due $Q$ (_se già ricevuto_);
- un $Q$ e un SI (_se non ricevuto_).

Una soluzione alternativa usa il protocollo traversal, però costruendo l'albero in sequenza andiamo un po' controllo l'approccio parallelo che ci piace. In ogni caso, per traversal i link sui quali viaggiano le return sono i link dentro Tree.
