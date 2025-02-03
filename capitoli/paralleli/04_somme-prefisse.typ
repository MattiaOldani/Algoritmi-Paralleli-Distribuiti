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

= Somme prefisse

Anche il problema delle *somme prefisse* userà il modulo della sommatoria per essere risolto.

Questo problema
- prende in *input* una serie di numeri $M[1], dots, M[n]$;
- restituisce in *output*, nella cella $k$-esima, la somma di tutti gli elementi precedenti più se stesso.

In poche parole, nella cella $k$-esima abbiamo la quantità $ M[k] = sum_(i=1)^k M[i] . $

Assumiamo, per semplicità, che $n$ sia una potenza di $2$.

Il migliore algoritmo sequenziale somma nella cella $i$ quello che c'è nella cella $i-1$.

#align(center)[
  #pseudocode-list(title: [*Algoritmo sequenziale furbo*])[
    + for $k = 2$ to $n$ do
      + $M[k] = M[k] + M[k-1]$
  ]
]

Il tempo di questo algoritmo è $T(n,1) = n-1$.

== Prima versione

Vediamo una prima proposta parallela. Al modulo sommatoria passo tutti i possibili prefissi: un modulo somma i primi due, un modulo i primi tre, eccetera.

Con questo approccio abbiamo un paio di problemi:
- l'algoritmo non è EREW, ma questo è facilmente risolvibile;
- l'algoritmo usa $p(n) = n^2 / log(n)$ processori con tempo $T(n,p(n)) = log(n)$.

Con questo dispendio di tempo e spazio, l'efficienza vale $ E = frac(n-1, n^2/log(n) log(n)) arrow.long 0 . $

== Seconda versione [pointer doubling]

Usiamo il *pointer doubling*, un algoritmo ideato da *Kogge-Stone* nel $1973$.

Dobbiamo stabilire dei legami tra i numeri, e ognuno di questi legami viene preso in carico da un processore, che ne fa la somma. Quest'ultima viene poi inserita nella cella di indice maggiore.

Alla prima iterazione ho dei link tra una cella e la successiva. Alla seconda iterazione ho dei link tra una cella e quella due posizioni dopo. Alla terza iterazione ho dei link tra una cella e quella quattro posizioni dopo. Alla quarta iterazione eccetera.

Notiamo due cose:
- la distanza dei link raddoppia ad ogni iterazione;
- alcuni processori non hanno dei successori, ovvero qualche processore non riesce a linkarsi con nessun altro elemento del vettore.

L'algoritmo termina quando non riesco più a mettere dei link tra celle di memoria.

Vediamo un po' di fatti che riguardano questo algoritmo:
- ogni volta raddoppiamo la distanza dei link, quindi l'algoritmo lavora in *tempo logaritmico*.
- prima di eseguire una somma e un aggiornamento di link al passo $i$, in quel momento erano attivi $n - 2^(i-1)$ processori.
- alla fine del passo $i$, il numero di processori senza successore è $2^i$.

Ci serve sicuramente un vettore di successori, che usiamo per ricavare le celle da sommare tra loro.

Sia $S$ tale vettore. Sia $S[k]$ il successore di $M[k]$. Come inizializzo $S$?

Prima della prima iterazione assegno
- $S[k] = k+1$;
- $S[n] = 0$.

#align(center)[
  #pseudocode-list(title: [*Algoritmo di Kogge-Stone*])[
    + for $i = 1$ to $log(n)$ do
      + for $1 lt.eq k lt.eq n - 2^(i - 1)$ par do
        + $M[S[k]] = M[k] + M[S[k]]$
        + $S[k] = S[S[k]]$
  ]
]

L'algoritmo incredibilmente è EREW perché accediamo sì alle stesse celle, ma in momenti diversi.

#theorem()[
  L'algoritmo di Kogge-Stone è corretto.
]

#proof()[
  Siamo in una EREW-PRAM, quindi il processore $P_i$ lavora su $M[i]$ e $M[S[i]]$, e se considero $i eq.not j$ allora $S[i] eq.not S[j]$ e quindi abbiamo successori diversi (_accettiamo il caso in cui entrambi i successori sono nulli_).

  Devo dimostrare che nella cella $k$-esima cella ho la somma degli elementi precedenti più l'elemento stesso. Vale la proprietà che dice che all'$i$ esimo passo vale $ M[t] = cases(M[t] + dots + M[1] & "se" t lt.eq 2^i, M[t] + dots + M[t - 2^i + 1] quad & "se" t > 2^i) . $

  Se $i = log(n)$, ovvero sono all'ultima iterazione, siamo nel primo caso della funzione definita a tratti e quindi vale $ M[t] = M[t] + dots + M[1] . qedhere $
]

Mostriamo che vale la proprietà descritta nella dimostrazione precedente.

#proof()[
  Dimostriamo questa proprietà per induzione su $i$

  *Caso base*: se $i = 1$ allora:
  - se $t lt.eq 2$ allora $M[1] = M[1]$ e $M[2] = M[2] + M[1]$;
  - se $t > 2$ allora $M[t] = M[t] + M[t-1]$.

  *Passo induttivo*: assumo vero per $i - 1$ e dimostro vero per $i$.

  Prima di iniziare il passo $i$-esimo il vettore $S$ contiene $ S[k] = cases(k + 2^(i - 1) quad & "se" k lt.eq n - 2^(i - 1), 0 & "se" k > n - 2^(i - 1)) . $

  Le celle con indice $lt.eq 2^(i - 1)$ hanno la proprietà vera per ipotesi induttiva.

  Concentriamoci sugli indici che avanzano da analizzare.

  Se $2^(i - 1) < t lt.eq 2^i$ allora possiamo scrivere $t$ come $t = 2^(i - 1) + a$ e quindi $ M[a + 2^(i - 1)] &= underbracket(M[a], a lt.eq 2^(i - 1)) + underbracket(M[a + 2^(i - 1)], a + 2^(i - 1) > 2^(i - 1)) = \ &= M[1] + dots + M[a] + bar.v + M[a + 1] + dots + A[a + 2^(i - 1)] . $

  Se invece $t > 2^i$ allora possiamo scrivere $t$ come $t = a + 2^i$ e quindi $ M[a + 2^i] &= M[(a + 2^(i - 1)) + 2^(i - 1)] = underbracket(M[a + 2^(i - 1)], a + 2^(i - 1) > 2^(i - 1)) + underbracket([a + 2^i], a + 2^i > 2^(i - 1)) = \ &= M[a + 1] + dots + M[a + 2^(i - 1)] + bar.v + M[a + 2^(i - 1) + 1] + dots + M[a + 2^i] . $

  In entrambi gli indici mancanti la proprietà risulta vera.
]

Valutiamo infine questo algoritmo: esso utilizza $p(n) = n-1$ processori con un utilizzo di tempo uguale a $T(n,p(n)) = 8 log(n)$. Il fattore logaritmico viene dal passo parallelo. L'efficienza è quindi $ E = frac(n-1, (n-1) 8 log(n)) = frac(1, 8 log(n)) arrow.long 0 . $

Anche se l'efficienza tende a $0$ lentamente, non siamo soddisfatti di questa soluzione.

Sfruttiamo il *principio di Wyllie* per far sparire il fattore $log(n)$ dal denominatore. Usiamo quindi $p(n) = O(n/log(n))$ processori, ottenendo sempre un tempo logaritmico ma andremo ad avere $ E = frac(n - 1, c_1 frac(n, log(n)) c_2 log(n)) = frac(n - 1, c_1 c_2 n) arrow.long C eq.not 0 . $

Questo problema può essere usato come modulo per risolvere il problema *OP-prefissa*, dove non devo più utilizzare la somma come operazione associativa ma devo usare una operazione *OP* generica.
