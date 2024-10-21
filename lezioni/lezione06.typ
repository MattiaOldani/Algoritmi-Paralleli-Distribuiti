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


= Lezione 06

== Ancora sommatoria

=== Dimostrazione

Finiamo la dimostrazione della scorsa lezione.

#proof()[
  Per dimostrare che è corretto mostriamo che al passo parallelo $i$ nella cella $2^i k$ ho i $2^i - 1$ valori precedenti, sommati a $M[2^i k]$, ovvero che $M[2^i k] = M[2^i k] + dots + M[2^i (k-1) + 1]$.

  Notiamo che se $i = log(n)$ allora ho un solo processore $k=1$ e ottengo la definizione di sommatoria, ovvero $M[n] = M[n] + dots + M[1]$.

  Dimostriamo per induzione.

  Passo base: se $i = 1$ allora $M[2k] = M[2k] + M[2k-1]$.

  Passo induttivo: supponiamo sia vero per $i-1$, dimostriamo che vale per $i$. Sappiamo che al generico passo $k$ eseguiamo l'operazione $M[2^i k] = M[2^i k] + M[2^i k - 2^(i-1)]$.

  Andiamo a riscrivere i due fattori della somma in un modo a noi più comodo:
  - $M[2^i k] = M[2^(i-1) dot 2k] = M[2^(i-1) dot 2k] + dots + M[2^(i-1) dot (2k - 1) + 1]$ perché vale l'ipotesi del passo induttivo;
  - $M[2^i k - 2^(i-1)] = M[2^(i-1) dot (2k - 1)] = M[2^(i-1) dot (2k - 1)] + dots + M[2^(i-1) dot (2k - 2) + 1]$ sempre per l'ipotesi del passo induttivo.

  Notiamo ora che il primo e il secondo fattore sono contigui: infatti, l'ultima cella del primo fattore è un indice superiore rispetto alla prima della del secondo fattore. Inoltre, l'ultima cella del secondo fattore $M[2^(i-1) dot (2k - 2) + 1]$ può essere riscritta come $M[2^i (k - 1) + 1]$, quindi abbiamo ottenuto esattamente quello che volevamo dimostrare.
]

=== Valutazione

Se $n$ è potenza di $2$ usiamo un numero massimo di processori uguale a $n/2$ e un tempo $T(n, n/2) = 4 log(n)$, dovuto alle microistruzioni che vengono fatte in ogni passo parallelo.

Se $n$ non è potenza di $2$ dobbiamo "allungare" l'input fino a raggiungere una dimensione uguale alla potenza di $2$ più vicina, aggiungendo degli zeri in coda, ma questo non va ad intaccare le prestazioni perché la nuova dimensione è limitata da $2n$.

Infatti, con lunghezza $2n$ abbiamo un numero di processori uguale a $n$ e un tempo $T(n, n) = 4 log(2n) lt.eq 5 log(n)$. In poche parole:
- $p(n) = O(n)$;
- $T(n, p(n)) = O(log(n))$.

Se però calcoliamo l'efficienza otteniamo $ E(n,n) = frac(n-1, n dot 5 log(n)) arrow.long 0 , $ quindi dobbiamo trovare una soluzione migliore, anche se $E$ tende a $0$ lentamente.

== Sommatoria ottimizzata

Il problema principale di questo approccio è che i processori sono un po' sprecati: prima vengono utilizzati tutti, poi ne vengono usati sempre di meno. Usiamo l'approccio di Wyllie: vogliamo arrivare ad avere $E arrow.long k eq.not 0$ diminuendo il numero di processori utilizzati.

Andiamo quindi ad utilizzare $p$ processori, con $p < n$, raggruppando i numeri presenti in $M$ in gruppi grandi $Delta = n / p$, ognuno associato ad un processore.

Come prima, andiamo a mettere la somma di un gruppo $Delta_i$ nella cella di indice maggiore. Al primo passo parallelo ogni processore esegue la somma sequenziale dei $Delta$ valori contenuti nel proprio gruppo, ovvero $M[k Delta] = M[k Delta] + dots + M[(k-1) Delta + 1]$. I successivi passi paralleli eseguono l'algoritmo sommatoria proposto prima sulle celle di memoria $M[Delta], M[2 Delta], dots, M[p Delta]$, e in quest'ultima viene inserito il risultato finale.

=== Valutazione

In questa versione ottimizzata usiamo $p(n) = p$ processori e abbiamo un tempo $T(n, p)$ formato dal primo passo parallelo "di ottimizzazione" sommato al tempo dei passi successivi, quindi $T(n,p) = n / p + 5 log(p)$.

Andiamo a calcolare l'efficienza $E(n,p) = frac(n-1, p dot (n / p + 5 log(p))) = frac(n-1, n + underbracket(5 p log(p), n)) approx n / (2n) = 1 / 2$, che è il valore diverso da $0$ che volevamo.

Per fare questo dobbiamo imporre $5 p log(p) = n$, quindi $p = frac(n, 5 log(n))$ (anche se non ho ben capito questo cambio di variabile, ma va bene lo stesso).

Con questa assunzione riusciamo ad ottenere un tempo $T(n, p(n)) = 5 log(n) + dots + 5 log(n) lt.eq 10 log(n)$.
