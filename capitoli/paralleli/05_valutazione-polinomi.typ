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

= Valutazione di polinomi

Questo problema
- prende in *input* un polinomio $p(x) = a_0 + a_1 x + dots + a_n x^n$ e un valore $alpha in RR$;
- restituisce in *output* la valutazione di $p$ nel valore $alpha$, ovvero $p(alpha)$.

In memoria ho il valore $alpha$ e i coefficienti del polinomio $A[0], dots, A[n]$.

L'algoritmo sequenziale esegue circa $n^2$ operazioni, tra somme e prodotti.

Con il metodo di *Ruffini-Horner* possiamo abbassare il numero di operazioni. L'idea che hanno avuto questi pazzi è quella di eseguire un raccoglimento di $x$ iterativo, ottenendo $ p(x) = a_0 + x(a_1 + dots (a_(n-2) + x(a_(n-1) + a_n x)) dots ) . $

Partiamo con $p = a^n$. Ad ogni passo dell'algoritmo calcoliamo somma+prodotto di una parentesi e assegniamo questo valore di nuovo a $p$. Vale quindi che $ p = a_i + p alpha . $

#align(center)[
  #pseudocode-list(title: [*Algoritmo di Ruffini-Horner*])[
    + $p = a_n$
    + for $i=1$ to $n$ do
      + $p = a_(n-i) + p alpha$
    + *output* $p$
  ]
]

Contando le $2$ operazioni elementari, questo tempo sequenziale vale $T(n,1) = 2n$.

Per l'algoritmo parallelo dobbiamo:
- costruire il vettore delle potenze di $alpha$, chiamato $Q$, e tale che $Q[k] = alpha^k bar.v 0 lt.eq k lt.eq n$;
- eseguire il prodotto interno tra $A$ e $Q$.

Il vettore $Q$ possiamo calcolarlo grazie al problema *replica*: dobbiamo mettere $alpha$ in tutti gli elementi di $Q$ da $1$ a $n$, e poi applicare il prodotto prefisso.

#align(center)[
  #pseudocode-list(title: [*Replica*])[
    + for $k=1$ to $n$ par do
      + $Q[k] = alpha$
  ]
]

L'algoritmo scritto è CREW, perché $alpha$ è in memoria e quindi ho accesso simultaneo al dato, usa $p(n) = n$ processori con tempo $T(n,p(n)) = 2$. L'efficienza vale $ E = frac(n, 2n) = 1/2 eq.not 0 . $

Possiamo modificare leggermente il modulo replica, perché se poi lo dobbiamo utilizzare prima del prodotto prefisso molti processori vengono inutilizzati. Abbassiamo quindi il numero di processori con il *principio di Wyllie*, raggruppando in gruppi di $log(n)$ elementi l'input. Il $k$-esimo processore carica $alpha$ nelle celle di indice $ (k-1) log(n) + 1 quad bar.v quad dots quad bar.v quad k log(n) . $

#align(center)[
  #pseudocode-list(title: [*Replica migliorato*])[
    + for $k=1$ to $n/log(n)$ par do
      + for $i=1$ to $log(n)$ do
        - $Q[(k-1) log(n) + i] = alpha$
  ]
]

Questa nuova versione usa $p(n) = n/log(n)$ processori con tempo $t = c log(n)$. L'efficienza vale $ E = frac(n, c frac(n, log(n)) log(n)) = 1/c eq.not 0 . $

Anche questa versione però rimane CREW per l'accesso ad $alpha$. Noi però vorremmo un EREW, quindi:
- costruiamo il vettore $[alpha, 0, dots, 0]$;
- eseguiamo somme prefisse

#align(center)[
  #pseudocode-list(title: [*Replica ancora migliore*])[
    + $Q[1] = alpha$
    + for $k=2$ to $n$ par do
      + $Q[k] = 0$
    + SommePrefisse($Q$)
  ]
]

Posso anche ridurre i processori con il *principio di Wyllie*, usando
- $p(n) = n/log(n)$ processori e tempo $T(n,p(n)) = log(n)$ per costruire $Q$;
- $p(n) = n/log(n)$ processori e tempo $T(n,p(n)) = log(n)$ per le somme prefisse.

Finalmente abbiamo un algoritmo EREW.

#align(center)[
  #pseudocode-list(title: [*Valutazioni di polinomi parallela*])[
    + Replica($Q$, $alpha$)
    + ProdottoPrefisso($Q$)
    + ProdottoInterno($A$, $Q$)
  ]
]

Tutti i moduli utilizzati in questa ultima versione dell'algoritmo usano $p(n) = n / log(n)$ processori con tempo $T(n,p(n)) = log(n)$. L'efficienza, anche in questo caso, tende a $C eq.not 0$.
