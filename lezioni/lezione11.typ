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


= Lezione 11

== Ordinamento

Detto problema del *ranking*, abbiamo in input $M[1], dots, M[n]$ e vogliamo in output una permutazione $p : {1,dots,n} arrow.long {1,dots,n}$ tale che $M[p(1)] lt.eq dots lt.eq M[p(n)]$ con $p(i)$ indice dell'elemento del vettore $M$ che va in posizione $i$. Potremmo anche ordinare direttamente in $M$, ma noi usiamo gli indici. Quindi la funzione, dato un indice, mi dice che elemento va in quell'indice.

In genere, gli algoritmi di ordinamento sono basati sui confronti, ovvero $M[i] lt.eq M[j] ? "SI" : "NO"$. Questi algoritmi hanno tempo $t = Theta(n log(n))$:
- upper bound: esistono algoritmi che impiegano al massimo quello, tipo merge sort
- lower bound: gli algoritmi di ordinamento creano degli alberi di decisione, ogni nodo è un confronto, SX positiva DX negativa. Ottengo un albero binario di decisione. Le foglie sono le permutazioni dell'input: ogni foglia individua un cammino a partire dalla radice e quindi i confronti che mi permettono di ordinare l'input. L'altezza dell'albero è il numero di confronti effettuati nel caso peggiore, ma questo è anche il tempo dell'algoritmo di ordinamento. Le possibili permutazioni dell'input sono $n!$, quindi $"foglie" gt.eq n!$. Se $t$ è l'altezza, allora il massimo numero di foglie è $2^t$, quindi $ 2^t gt.eq "foglie" gt.eq n! arrow.long.double t gt.eq log_2(n!) \ log_2(n!) gt.eq log_2(product_(i=n/2+1)^n i) gt.eq log_2(n/2)^(n/2) = n/2 log_2(n/2) tilde n log_2(n) . $ Con la formula di Stirling è sicuramente più bella la dimostrazione. Quindi l'altezza è almeno $n log(n)$ ma questo era il tempo quindi il tempo è così.

== Primo approccio parallelo [counting sort]

ALgoritmo basato sul conteggio, ovvero conta i confronti, sequenzialmente ha $t = Theta(n^2)$ perché deve confrontare tutte le coppie. Assumiamo che $n$ sia potenza di $2$ e che gli elementi siano diversi tra loro.

Prendiamo d'esempio il counting sort sequenziale, ovvero $M[i]$ va in posizione $k$ se e solo se $k$ elementi sono $lt.eq M[i]$ in $M$.

Usiamo il vettore $V[1], dots, V[n]$ con $V[i]$ che contiene $k$. In poche parole, è la permutazione inversa di $p$, perché sto dicendo che l'elemento $i$ va in posizione $k$. Dell'elemento so la sua posizione finale. Infatti:
- permutazione normale: ti do la posizione, mi dici che elemento ci va
- permutazione inversa: ti do l'elemento, mi dici in che posizione va

#align(center)[
  #pseudocode-list(title: [Counting Sort sequenziale])[
    + for $i = 1$ to $n$
      + $V[i] = 0$
    + for $i = 1$ to $n$
      + for $j = 1$ to $n$
        + if $M[j] lt.eq M[i]$
          + $V[i] = V[i] + 1$
    + for $i = 1$ to $n$
      + $F[v[i]] = M[i]$
    + for $i = 1$ to $n$
      + $M[i] = F[i]$
  ]
]

Le prime due fasi vanno già bene, le ultime due servono solo per ordinare effettivamente il vettore. Il numero di confronti è $n^2$, visto il doppio for della fase $2$. Fase più pesante è questa, e il tempo è $t = n^2$.

La versione parallela ha $forall i,j$ un processore $p_(i j)$ che calcola $M[j] lt.eq M[i]$ e aggiorna una matrice booleana $V[i,j]$ con il risultato del confronto. L'$i$-esima riga individua gli elementi di $M$ che sono $lt.eq M[i]$. Poi, $forall i$ effettuo una sommatoria parallela dell'$i$-esima riga. Ottengo un vettore colonna $V[1,n], dots, V[n,n]$ che coincide con $V[1], dots, V[n]$.

#align(center)[
  #pseudocode-list(title: [Counting Sort parallelo])[
    + for $i lt.eq n and j lt.eq n$ par do
      + $V[i,j] = (M[j] lt.eq M[i] ? 1 : 0)$
    + for $i = 1$ to $n$ par do
      + $"SOMMATORIA"(V[i,1], dots, V[i,n])$
    + for $i = 1$ to $n$ par do
      + $M[V[i]] = M[i]$
  ]
]

Non è mai nella vita EREW, faccio lettura concorrente, ma la scrittura non è concorrente visto che scrivo in ogni cella diversa, quindi CREW

Vediamo le prestazioni:
- fase $1$ ho $p = n^2$ e $T(n,n^2) = 4$ per LD LD JE ST
- fase $1$ con Wyllie ho $p = n^2 / log(n)$ e $T = log(n)$
- fase $2$ è sommatoria quindi $p = n^2 / log(n)$ perché $n$ moduli sommatoria e $t = log(n)$
- fase $3$ ho $p = n$ e $T = 3$ LD LD ST

Totale quindi è $p = n^2 / log(n)$ e $T = log(n)$, allora $ E = frac(n log(n), n^2 / log(n) log(n)) = log(n) / n arrow.long 0 $ e nemmeno lentamente.

Un algoritmo migliore è bit sort (bitonic sort), che ha efficienza $E = 1/log(n) arrow.long 0$ ma lentamente. Un altro ottimo è quello di Cole del 1988 ma non lo vedremo, nonostante abbia $E = C eq.not 0$.

== Secondo approccio parallelo [bitonic sort]

Prendiamo spunto dal merge sort, che usa la tecnica divide et impera.

#align(center)[
  #pseudocode-list(title: [MergeSort])[
    - input $A[1], dots, A[n]$
    + if $abs(A) > 1$
      + $A_s = "MergeSort"(A[1], dots, A[n / 2])$
      + $A_d = "MergeSort"(A[n / 2 + 1], dots, A[n])$
      + $A = "Merge"(A_s, A_d)$
    + return $A$
  ]
]

La routine merge scorre in sequenza i due array ordinati, confronta i valori correnti e li mette in $A$. Il tempo peggiore è $n$.

Il tempo di MergeSort è $ t(n) = cases(0 & "se" n = 1, 2 t(n/2) + n quad & "altrimenti") . $

Se svogliamo otteniamo $ t(n) = 2 t (n/2) + n tilde 2(2 t(n/4)) + n + n tilde dots tilde 2^k t(n/2^k) + k n =_(k = log(n)) = n dot 0 + n log(n) = n log(n) . $

Sfruttiamo questa cosa: divido continuamente il vettore fino ad arrivare ad un elemento. Qua devo fare il merge, se usassi il parallelo avrei $log(n)-1$ passi paralleli essendo un albero. Ma merge non è parallelizzabile e quindi avrei sempre $T tilde n log(n)$.

Ci chiediamo: quando merge è facile? Supponiamo $A_s$ e $A_d$ ordinati ma gli elementi di $A_s$ tutti minori di $A_d$: basta concatenarli e basta. Useremo sequenze di numeri particolari, dette *bitoniche*.

Dobbiamo trasformare l'input in quella forma per rendere la vita facile al merge.

Abbiamo bisogno di qualche routine:
- $"rev"(A[1], dots, A[n]) : A[1] = A[n], dots, A[n] = A[1]$;
- $"minmax"(A[1], dots, A[n])$ che non ho capito.
