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

= Applicazioni di sommatoria

Il problema sommatoria lo possiamo utilizzare come modulo per risolvere dei problemi più complessi. In questo capitolo vediamo quattro problemi molto semplici.

== Prodotto interno di vettori

Questo problema:
- prende in *input* due vettori $x,y in NN^n$;
- restituisce in *output* il *prodotto scalare*.

Il prodotto scalare è un numero reale definito dalla formula $ angle.l x,y angle.r = sum_(i=1)^n x_i y_i . $

Il miglior tempo sequenziale è $T(n,1) = 2n-1$, formato da $n$ prodotti e $n-1$ somme finali.

Il modulo sommatoria viene usato per eseguire le somme finali in parallelo. L'algoritmo che vedremo si articola in due fasi:
- eseguo $log(n)$ prodotti in sequenza delle componenti e la somma dei valori del blocco in sequenza;
- effettuo la somma di $p = n/log(n)$ prodotti in parallelo.

Per sommatoria ci serviranno $p = c_1 n/log(n)$ processori, con tempo $t = c_2 log(n)$. Per la prima fase ci serviranno invece $p = n/log(n)$ processori, con tempo $t = c_3 log(n)$.

Ma allora utilizziamo in totale $p = n/log(n)$ processori con tempo $t = log(n)$. L'efficienza è $ E = frac(2n-1, n/log(n) dot log(n)) arrow.long C eq.not 0 . $

== Prodotto matrice vettore

Questo problema:
- prende in *input* una matrice $A in NN^(n times n)$ e un vettore $x in NN^n$;
- restituisce in *output* il prodotto $A x$.

Per questo problema usiamo il prodotto interno di vettori come modulo.

Il migliore tempo sequenziale è $T(n,1) = n(2n-1) = 2n^2 - n$.

Per l'approccio parallelo, l'idea è usare il modulo del prodotto interno in parallelo per $n$ volte. Il vettore se è acceduto simultaneamente dai moduli precedenti ci obbliga ad avere una politica CREW.

Questa idea utilizza $p(n) = n^2/log(n)$ processori con tempo $T(n,p(n)) = log(n)$. 'efficienza vale $ E = frac(n^2, n^2/log(n) log(n)) arrow.long C eq.not 0 . $

== Prodotto matrice matrice

Questo problema:
- prende in *input* due matrici $A,B in NN^(n times n)$;
- restituisce in *output* il prodotto matriciale $A B$.

Usiamo ancora il prodotto interno come modulo per risolvere questo problema.

Il miglior tempo sequenziale è $T(n,1) = n^(2.8)$, ottenuto con *l'algoritmo di Strassen*.

Come prima, l'idea è fare dei prodotti interni paralleli, solo che in questo caso sono $n^2$. Ci servirà ancora la politica CREW, per via dell'accesso simultaneo alle righe di $A$ e alle colonne di $B$.

Questo algoritmo usa $p(n) = n^3/log(n)$ processori con tempo $T(n,p(n)) = log(n)$. L'efficienza vale $ E = frac(n^(2.80), n^3/log(n) log(n)) arrow.long 0 . $

L'efficienza tende a $0$ ma lentamente, quindi lo accettiamo come risultato.

== Potenza di matrice

Questo ultimo problema:
- prende in *input* una matrice $A in NN^(n times n)$;
- restituisce in *output* la potenza $A^t$, con $t = 2^k$.

Questo problema si risolve come prodotto iterato con tempo $T(n,1) = n^2.80 log(n)$.

#align(center)[
  #pseudocode-list(title: [*Potenza di matrice sequenziale*])[
    + for $i = 1$ to $log(n)$ do
      + $A = A dot A$
  ]
]

L'approccio parallelo per $log(n)$ volte esegue il prodotto $A dot A$, anche questo con politica CREW.

Per questo problema utilizziamo $p(n) = n^3 / log(n)$ processori con tempo $T(n,p(n)) = log^2 (n)$.

Purtroppo, l'efficienza che otteniamo è $ E = frac(n^(2.8) log(n), n^3 / log(n) dot log^2 (n)) = frac(n^2.8, n^3) arrow.long 0 . $ Come prima però, accettiamo l'efficienza visto che tende a $0$ lentamente.
