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


= Lezione 10

== Ancora valutazione di polinomi

#align(center)[
  #pseudocode-list()[
    + for $k=1$ to $n$ par do:
      + $Q[k] = alpha$
  ]
]

L'algoritmo scritto è CREW (perché alpha è in memoria quindi ho accesso simultaneo), ha processori $p=n$, tempo $t=2$ e quindi efficienza $E arrow 1/2 eq.not 0$. Se REPLICA è un modulo da usare forse posso fare meglio perché al passo dopo (con prodotto prefisso) ne uso di meno.

Abbassiamo il numero di processori con Willye, raggruppiamo in $log(n)$ elementi. Il $k$-esimo processore carica $alpha$ nelle celle di pozione $(k-1) log(n) + 1, dots, k log(n)$.

Il secondo metodo è il seguente.

#align(center)[
  #pseudocode-list()[
    + for $k=1$ to $n/log(n)$ par do
      + for $i=1$ to $log(n)$ do
        - $Q[(k-1) log(n) + i] = alpha$
  ]
]

Ha processori $p = n/log(n)$, tempo $t = c log(n)$ e efficienza $E = 1/c eq.not 0$. Rimane sempre CREW per l'accesso ad $alpha$ simultaneo.

Vorremmo un EREW, quindi:
- costruiamo il vettore $alpha, 0, dots, 0$;
- eseguiamo somme prefisse

#align(center)[
  #pseudocode-list()[
    + $Q[1] = alpha$
    + for $k=2$ to $n$ par do
      + $Q[k] = 0$
  ]
]

Posso anche ridurre i processori con Willye, avendo $p = n/log(n)$ e tempo $t = log(n)$ per costruire il vettore e poi usare le somme prefisse con $p = n/log(n)$ e tempo $t = log(n)$. Ora abbiamo un EREW.

Cosa abbiamo fatto quindi:
- $A$ ce l'abbiamo in memoria;
- REPLICA di $alpha$;
- prodotto prefisso;
- prodotto interno.

I processori sono $n/log(n)$ e il tempo $log(n)$, quindi l'efficienza è $C eq.not 0$.

== Ricerca di un elemento

- *Input*: $M[1], dots, M[n]$ e $alpha$;
- *Output*: $M[n] = 1$ se $alpha in M$, altrimenti $0$.

Il sequenziale classico ha $t(n) = n$ (se ordinato è logaritmico).

Un algoritmo quantistico su non ordinato è $t = sqrt(n)$ (usa interferenza quantistica).

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

Ho la CR in $alpha$ e la CW in $F$. I processori sono $n$ e il tempo è costante, quindi $ E =  $

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
- posizione minima di $alpha$ in $M$, usando una OP iterata tale che $ "OP"(x,y) = cases(min(x,y) "se" x,y eq.not 0, max(x,y) "altrimenti") . $
