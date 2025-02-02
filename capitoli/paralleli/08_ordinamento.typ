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

= Ordinamento

Detto problema del *ranking*, abbiamo in input $M[1], dots, M[n]$ e vogliamo in output una permutazione $p : {1,dots,n} arrow.long {1,dots,n}$ tale che $M[p(1)] lt.eq dots lt.eq M[p(n)]$ con $p(i)$ indice dell'elemento del vettore $M$ che va in posizione $i$. Potremmo anche ordinare direttamente in $M$, ma noi usiamo gli indici. Quindi la funzione, dato un indice, mi dice che elemento va in quell'indice.

In genere, gli algoritmi di ordinamento sono basati sui confronti, ovvero $M[i] lt.eq M[j] ? "SI" : "NO"$. Questi algoritmi hanno tempo $t = Theta(n log(n))$:
- upper bound: esistono algoritmi che impiegano al massimo quello, tipo merge sort
- lower bound: gli algoritmi di ordinamento creano degli alberi di decisione, ogni nodo è un confronto, SX positiva DX negativa. Ottengo un albero binario di decisione. Le foglie sono le permutazioni dell'input: ogni foglia individua un cammino a partire dalla radice e quindi i confronti che mi permettono di ordinare l'input. L'altezza dell'albero è il numero di confronti effettuati nel caso peggiore, ma questo è anche il tempo dell'algoritmo di ordinamento. Le possibili permutazioni dell'input sono $n!$, quindi $"foglie" gt.eq n!$. Se $t$ è l'altezza, allora il massimo numero di foglie è $2^t$, quindi $ 2^t gt.eq "foglie" gt.eq n! arrow.long.double t gt.eq log_2(n!) \ log_2(n!) gt.eq log_2(product_(i=n/2+1)^n i) gt.eq log_2(n/2)^(n/2) = n/2 log_2(n/2) tilde n log_2(n) . $ Con la formula di Stirling è sicuramente più bella la dimostrazione. Quindi l'altezza è almeno $n log(n)$ ma questo era il tempo quindi il tempo è così.

== Prima versione [counting sort]

Algoritmo basato sul conteggio, ovvero conta i confronti, sequenzialmente ha $t = Theta(n^2)$ perché deve confrontare tutte le coppie. Assumiamo che $n$ sia potenza di $2$ e che gli elementi siano diversi tra loro.

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

== Seconda versione [bitonic sort]

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

Due operazioni fondamentali:
- REV per fare il reverse *in parallelo*, $"rev"(A[1], dots, A[n]) : A[1] = A[n], dots, A[n] = A[1]$;;
- MINMAX che costruisce gli array $A_min$ e $A_max$; divide a metà e prende i valori a distanza $n/2$ e mette il minimo in quello a sx e il massimo a dx; nella prima metà avrò i minimi e nella seconda metà avrò i massimi; ritorniamo poi $A_min A_max$.

Vediamo le procedure.

#align(center)[
  #pseudocode-list(title: [Reverse])[
    + for $1 lt.eq k lt.eq n/2$ par do
      + $"SWAP"(A[k], A[n-k+1])$
  ]
]

Ho $p = n/2$ processori e $t = 4$ per LD LD ST ST.

#align(center)[
  #pseudocode-list(title: [MinMax])[
    + for $1 lt.eq k lt.eq n/2$ par do
      + if $A[k] > A[k + n/2]$
        + $"SWAP"(A[k], A[k + n / 2])$
  ]
]

Ho $p = n/2$ processori e $t = 5$ per LD LD ST ST e confronto.

Diamo alcune definizioni di particolari sequenze numeriche:
- unimodale: $A$ è unimodale se e solo se $ exists k bar.v A[1] > A[2] > dots > A[k] < A[k+1] < dots < A[n] $ oppure $ A[1] < A[2] < dots < A[k] > A[k+1] > dots > A[n] $ ovvero esiste un valore che mi fa da minimo/massimo e la sequenza è decrescente/crescente poi crescente/decrescente. Non è perfettamente ordinato;
- bitonica: $A$ è bitonica se e solo se esiste una permutazione ciclica di $A$ che mi dà una sequenza unimodale, ovvero se $ exists j bar.v A[j], dots, A[n], A[1], dots, A[j-1] $ è unimodale. In poche parole, scelgo un elemento che va in testa e da li, ciclicamente, prendo tutto il resto del vettore; una volta fatto ciò, ho una roba unimodale.

Graficamente, una sequenza unimodale ha un picco (massimo o minimo), mentre una sequenza bitonica ha due picchi, un minimo+massimo con i valori della coda-min più piccoli dei valori della coda-max (coda-max > coda-min) oppure un massimo+minimo con coda-max valori più grandi dei valori di coda-min.

Vediamo l'algoritmo per ordinare sequenze bitoniche di Batcher del 1968.

Osserviamo che:
- una sequenza unimodale è anche bitonica, con la permutazione identità;
- i valori di fine vettore devono essere maggiori di inizio vettore (minmax) oppure devono essere minori di inizio vettore (maxmin);
- siano $A,B$ due sequenze ordinate, allora $A dot "REV"(B)$ è unimodale.

Vediamo delle proprietà ora.

#lemma()[
  Sia $A$ bitonica, se eseguo minmax su $A$ ottengo:
  - $A_min$ e $A_max$ bitonica;
  - ogni elemento di $A_min$ è minore di ogni elemento di $A_max$
]

#proof()[
  Dimostrazione grafica.
]

Ci suggeriscono un DEI:
- minmax suddivide il problema di $n$ elementi su istanze più piccole grazie alla prima parte;
- ordinando $A_min$ e $A_max$ la fusione di due sequenze ordinate avviene per concatenazione grazie alla seconda parte.

#align(center)[
  #pseudocode-list(title: [BitMerge sequenziale])[
    + input $A[1], dots, A[n]$ bitonico
    + minmax su $A$
    + if $abs(A) > 2$
      + BitonicSort su $A_min$
      + BitonicSort su $A_max$
    + return $A$
  ]
]

#theorem()[
  Corretto.
]

#proof()[
  Per induzione su $n$.

  Se $n = 2$ con minmax scambio se disordinati, poi ritorno $A$, quindi ok, banalmente ordinata da minmax.

  Sia $n = 2^k$ corretto, mostriamo per $n = 2^(k+1)$:
  - viene calcolato minmax su lunghezza $2^(k+1)$ che ritorna $A_min$ e $A_max$ di lunghezza $2^(k+1) / 2 = 2^k$;
  - ma su lunghezza $2^k$ BitMerge ordina perfettamente $A_min$ e $A_max$ per HP;
  - quindi $A$ viene ritornato ordinato.
]

Vediamo l'implementazione parallela.

Applichiamo MM con $n/2^0$, poi ..., infine $n/2^(i-1)$. In questo caso avviene una normalissima concatenazione, visto che MM lavora su due elementi.

Algoritmo EREW perché lavoro ogni volta su elementi diversi, no letture concorrenti.

Mi fermo quando $n/2^(i-1) = 2$ quindi $i = log(n)$. MM costa $5$ quindi $T(n) = 5 log(n)$. Il primo passo richiede $n/2$, il secondo $n/4 dot 2$, poi ..., quindi sempre $n/2$ processori.

L'equazione di ricorrenza è $ T(n) = cases(5 "se" n = 2, T(n/2) + 5 "altrimenti") $ non metto costanti alla $T$ perché sono in parallelo. Ottengo lo stesso $T(n) = 5 log(n)$.

L'efficienza è $ E = frac(n log(n), n/2 5 log(n)) arrow.long C eq.not 0 . $

== BitSort

Vediamo ora BitSort di Batcher del 1968, algoritmo per una qualunque sequenza.

#align(center)[
  #pseudocode-list(title: [BitSort sequenziale])[
    - input $A[1], dots, A[n]$ generico
    + minmax su $A$
    + if $abs(A) > 2$
      + BitSort su $A_min$
      + BitSort su $A_max$
      + BitMerge su $A_min dot "REV"(A_max)$ che è unimodale e quindi bitonica
    + return $A$
  ]
]

#theorem()[
  Correttezza.
]

#proof()[
  Per induzione su $n$.

  Caso base $n=2$ facciamo minmax così ho minimo+massimo, viene ritornato il vettore che è ordinato quindi SIUM.

  Suppongo vero per $n = 2^k$ e dimostro per $n = 2^(k+1)$.

  Sia $abs(A) = 2^(k+1)$, ma:
  - minmax divide $A$ in $A_min$ e $A_max$ di lunghezza $2^k$ entrambi
  - la chiamata ricorsiva (doppia) a BitSort prende $2^k$ ma per HP induttiva essi sono ordinati
  - la chiamata poi a bitmerge avviene con parametri C+D oppure D+C, ma BitMerge è corretto, quindi ordinato, poi viene ritornato.

  Vamos tutto corretto.
]

Vediamo l'implementazione parallela (serve immagine).

È un algoritmo PRAM-EREW perché dividiamo sempre l'input ma lavoriamo sempre su dati senza intersezione, accesso e scrittura esclusivi.

Tempo:
- prima fase è come bitmerge, quindi all'ultimo passo ho eseguito $i = log(n)$;
- seconda passo all'ultimo passo ho $i = log(n) - 1$ da moltiplicare per il costo di bitmerge che è logaritmico, quindi seconda fase è $T(n) = log^2(n)$.

Il costo totale è quindi quello della seconda fase, per i processori ho sempre $n/2$ in tutte le fasi.

Possiamo usare anche l'equazione di ricorrenza $ T(n) = cases(5 "se" n = 2, T(n/2) + 5 + 4 + 5 log(n) "altrimenti") $ senza costante sul $T(n/2)$ perché sono in parallelo. Facendo i conti si ottiene $  T(n) = frac(5 log^2(n) + 23 log(n) - 18, 2) . $

L'efficienza è $ E = frac(n log(n), n/2 5 log^2(n)) = alpha / log(n) arrow.long 0 $ molto lentamente. Ci va così piano che si preferisce su istanze molto piccole.

== Osservazioni

Buon algoritmo sequenziale non implica buon algoritmo parallelo: esempio è il MergeSort.

Ma anche buon algoritmo parallelo non implica buon algoritmo sequenziale: esempio è il BitSort.

Infatti, vediamo il tempo sequenziale di BitSort:
- prima BitMerge che vale $ T_m (n) = cases(O(1) "se" n = 2, 2 T_m (n/2) + O(n) "se" n > 2) $ quindi ci esce $T_b = O(n log(n))$;
- vediamo BitSort come $ T_s (n) = cases(O(1) "se" n = 2, 2 T_s (n/2) + O(n log(n)) "se" n > 2) $ che ci dà $T_s = O(n log^2(n))$

Vediamo come parallelo è buono perché è $O(log^2(n))$ mentre qua è $O(n log^2(n))$ che è peggio di MergeSort.
