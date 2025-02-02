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

= Valutazione di polinomi

Vediamo la definizione:
- *input*: $p(x) = a_0 + a_1 x + dots + a_n x^n$ e $alpha$;
- *output*: $p(alpha)$.

In memoria ho $alpha$ e $A[0], dots, A[n]$ che tiene i coefficienti.

L'algoritmo sequenziale fa $ sum_(i=0)^n i = n^2 ("prodotti") + n ("somme") approx n^2 $ operazioni nel metodo tradizionale.

Con *Ruffini-Horner* possiamo renderlo migliore, ovvero una raccolta di $x$ iterativa, ottenendo $ p(x) = a_0 + x(a_1 + dots (a_(n-2) + x(a_(n-1) + a_n x)) dots ) . $

Chiamo $p=a^n$, calcolo $a_(n-1) + a_n alpha$ e questo lo chiamo $p$ di nuovo e ricomincio. Vale $ p = a_j + p alpha . $

#align(center)[
  #pseudocode-list()[
    + $p = a_n$
    + for $i=1$ to $n$ do
      + $p = a_(n-i) + p alpha$
    + *output* $p$
  ]
]

Le operazioni sono $2$ per $n$ volte quindi $T(n,1) = 2n$ ed è sequenziale.

Che idea abbiamo per quello parallelo:
- costruisco il vettore delle potenze di $alpha$ e lo chiamo $Q$ ovvero $Q[k] = alpha^k quad 0 lt.eq k lt.eq n$;
- eseguo il prodotto interno tra $A$ e $Q$, ovvero $sum_(k=0)^n A[k] Q[k]$;
- ritorno il valore appena calcolato.

Come lo calcolo il vettore delle potenze? Metto $alpha$ in tutti gli elementi di $Q$ da $1$ a $n$, applico il prodotto prefisso per il problema REPLICA. Come risolvo replica in parallelo?

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
