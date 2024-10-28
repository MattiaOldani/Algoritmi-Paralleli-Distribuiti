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


= Lezione 09

== Ancora pointer doubling

Valutazione:
- $p(n) = n-1$;
- il passo di aggiornamento di $M$ vale $5$ mentre il passo di aggiornamento di $S$ vale $4$, quindi $T(n,n-1) approx 9 log(n)$ (il log viene dal passo parallelo).

L'efficienza è quindi $ E(n,p(n)) = frac(n-1, (n-1) 9 log(n)) = frac(1, 9 log(n)) arrow.long 0 $ ma lentamente, non va bene.

Sfruttiamo Willye per far sparire $log(n)$ da sotto.

Mettiamo $p(n) = O(n/log(n))$ quindi a gruppi di log(n), avremo sempre tempo logaritmico ma andremo ad avere efficienza diversa da $0$.

Questo può essere usato come modulo per OP-prefissa, dove in output ho $ M[k] = "op"_(i=1)^k M[i] quad 1 lt.eq k lt.eq n $ operazione associativa come prima.

== Valutazione di polinomi

- *Input*: $p(x) = a_0 + a_1 x + dots + a_n x^n$ e $alpha$;
- *Output*: $p(alpha)$.

In memoria ho $alpha$ e $A[0], dots, A[n]$ che tiene i coefficienti.

L'algoritmo sequenziale fa $sum_(i=0)^n i = n^2 ("prodotti") + n ("somme") approx n^2 $ operazioni nel metodo tradizionale.

Con Ruffini-Horner possiamo renderlo migliore, ovvero una raccolta di $x$ iterativa, ottenendo $ p(x) = a_0 + x(a_1 + dots (a_(n-2) + x(a_(n-1) + a_n x)) dots ) . $

Chiamo $p=a^n$, calcolo $a_(n-1) + a_n alpha$ e questo lo chiamo $p$ di nuovo e ricomincio. Vale $ p = a_j + p alpha . $

#align(center)[
  #pseudocode-list()[
    + $p = a_n$
    + for $i=1$ to $n$ do
      + $p = a_(n-i) + p alpha$
    + output $p$
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
    + for $k=1$ to $n$ par do
      + $Q[k] = alpha$
  ]
]

Da finire bene.
