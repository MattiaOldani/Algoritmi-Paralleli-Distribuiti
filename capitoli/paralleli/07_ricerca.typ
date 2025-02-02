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

/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/
#set heading(numbering: "1.")

#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(indent: auto)
/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/

= Ricerca

Problema definito da:
- *input*: $M[1], dots, M[n]$ e $alpha$;
- *output*: $M[n] = 1$ se $alpha in M$, altrimenti $0$.

Il sequenziale classico ha $t(n) = n$ (_se ordinato è logaritmico_).

Un algoritmo quantistico su non ordinato è $t = sqrt(n)$ (_usa l'interferenza quantistica_).

Vediamo un CRCW parallelo con una flag $F$.

#align(center)[
  #pseudocode-list()[
    + $F = 0$
    + for $k=1$ to $n$ par do
      + if $M[k] == alpha$
        + F = 1
    + $M[n] = F$
  ]
]

Perché usiamo $F$? Perché non posso sapere se poi $M[n] == 1$ è perché è il suo valore o perché l'ho trovato.

Ho la CR in $alpha$ e la CW in $F$. I processori sono $n$ e il tempo è costante, quindi $ E = frac(n, n c) = 1/c eq.not 0 . $

Vediamo un CREW ora, quindi senza flag.

#align(center)[
  #pseudocode-list()[
    + for $k=1$ to $n$ par do
      + $M[k] = (M[k] == alpha ? 1 : 0)$
    + MAX-iterato
  ]
]

Trasformiamo in un vettore booleano e poi vediamo il massimo. Abbiamo $n$ processori e tempo costante, ma con Willye andiamo a $p = n/log(n)$ e tempo $log(n)$, che sono uguali a quelli del max iterato. L'efficienza è quindi $E approx C eq.not 0$. Ho la CR per l'accesso ad alpha.

Vediamo infine un EREW.

#align(center)[
  #pseudocode-list()[
    + REPLICA $alpha$ in $A[1], dots, A[n]$
    + for $k=1$ to $n$ par do
      + $M[k] = (M[k] == A[k] ? 1 : 0)$
    + MAX-iterato
  ]
]

Le prestazioni di tutti hanno processori $p = n/log(n)$ e tempo $log(n)$, quindi l'efficienza vale $E = C eq.not 0$.

Varianti:
- conteggio di $alpha$ dentro $M$, usando sommatoria al posto di MAX;
- posizione massima di $alpha$ in $M$, assegnando $M[k] = k$ se c'è alpha nel vettore;
- posizione minima di $alpha$ in $M$, usando una OP iterata tale che $ "OP"(x,y) = cases(min(x,y) "se" x\,y eq.not 0, max(x,y) "altrimenti") . $
