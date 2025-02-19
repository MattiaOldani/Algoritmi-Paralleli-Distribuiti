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

= Ordinamento

Detto anche problema del *ranking*, questo problema:
- prende in *input* una serie di valori $M[1], dots, M[n]$;
- restituisce in *output* una *permutazione* $p : {1,dots,n} arrow.long {1,dots,n}$ tale che $ M[p(1)] lt.eq dots lt.eq M[p(n)], $ con $p(i)$ indice dell'elemento del vettore $M$ che va in posizione $i$.

Potremmo anche ordinare direttamente in $M$, ma noi decidiamo di usare gli indici.

In genere, gli algoritmi di ordinamento sono basati sui *confronti*, ovvero dei check nella forma $ M[i] lt.eq M[j] space ? space "SI" : "NO" . $

#theorem()[
  Gli algoritmi di ordinamento basati sui confronti hanno tempo $ T(n) = Theta(n log(n)) . $
]

#proof()[
  Dimostriamo i due bound di questi algoritmi:
  - upper bound: esistono algoritmi, tipo il merge sort, che impiegano al massimo $n log(n)$ passi per essere eseguiti;
  - lower bound: costruiamo un albero binario di decisione, dove ogni nodo è un possibile confronto. Il numero di foglie che otteniamo è il numero di permutazioni dell'input, che sono $n!$. L'altezza dell'albero è il numero di confronti che devo fare, perché un cammino dalla radice ad una foglia percorre tutti i confronti che devono essere fatti per ordinare l'input in quel preciso modo. Sappiamo che il numero di foglie di un albero binario è al massimo $2^h$, con $h$ altezza dell'albero, quindi $ 2^h gt.eq hash"foglie" = n! arrow.long.double_("STIRLING") h gt.eq log_2(sqrt(2 pi n) (n/e)^n) arrow.long.double h gt.eq n log(n) . $

  Quindi vale $Theta(n log(n))$.
]

== Counting sort

Vediamo un primo algoritmo di ordinamento, basato sul *conteggio*. Il *counting sort* conta i confronti. Sequenzialmente, il tempo è $T(n,1) = Theta(n^2)$ perché deve confrontare tutte le coppie. Assumiamo, per semplicità, che $n$ sia potenza di $2$ e che gli elementi siano tutti diversi tra loro.

Nel counting sort, $M[i]$ va in posizione $k$ se e solo se ci sono $k$ elementi $lt.eq M[i]$ in $M$.

Per effettuare questo conteggio, usiamo un vettore $V$ che contiene i vari valori di $k$ per ogni valore in $M$. Questo vettore è la *permutazione inversa* di $p$:
- prima, data una posizione, mi veniva detto che indice doveva finire in quel posto;
- ora, dato un indice, mi viene detto in che posizione devo finire.

#align(center)[
  #pseudocode-list(title: [*Counting Sort sequenziale*])[
    + for $i = 1$ to $n$
      + $V[i] = 0$
    + for $i = 1$ to $n$
      + for $j = 1$ to $n$
        + if $M[j] lt.eq M[i]$ then
          + $V[i] = V[i] + 1$
    + for $i = 1$ to $n$
      + $F[V[i]] = M[i]$
    + for $i = 1$ to $n$
      + $M[i] = F[i]$
  ]
]

I primi due cicli for andrebbero già bene, ma abbiamo aggiunto gli ultimi due for per ordinare effettivamente il vettore. Il numero di confronti è $O(n^2)$, visto il doppio ciclo for, quindi anche il tempo $T(n, p(n))$ assume quel valore.

La versione parallela utilizza un processore per ogni coppia di indici $(i,j)$ che calcola $M[j] lt.eq M[i]$ e aggiorna una matrice booleana $V[i,j]$ con il risultato del confronto. Notiamo come l'$i$-esima riga individua gli elementi di $M$ che sono $lt.eq M[i]$ quando la cella contiene il valore $1$.

Per ottenere il numero di elementi complessivo, che effettivamente ci interessa, eseguo la sommatoria parallela sulle righe, ottenendo un vettore colonna $V[i,n]$ che coincide con il vettore $V$ della versione sequenziale precedente.

#align(center)[
  #pseudocode-list(title: [*Counting Sort parallelo*])[
    + for $i lt.eq n and j lt.eq n$ par do
      + $V[i,j] = (M[j] lt.eq M[i] space ? space 1 : 0)$
    + for $i = 1$ to $n$ par do
      + Sommatoria($V[i,1], dots, V[i,n]$)
    + for $i = 1$ to $n$ par do
      + $M[V[i]] = M[i]$
  ]
]

Questo algoritmo non è assolutamente EREW, vista la lettura concorrente, ma la scrittura non lo è invece, visto che scriviamo in celle ogni volta diverse. L'algoritmo è quindi CREW.

Per il primo ciclo for usiamo $p(n) = n^2$ processori con tempo $T(n,p(n)) = 4$, che però con il *principio di Wyllie* trasformiamo in $p(n) = n^2 / log(n)$ processori con tempo $T(n,p(n)) = log(n)$.

Per il secondo ciclo for usiamo $p(n) = n^2 / log(n)$ processori, ovvero $n$ modulo sommatoria da $n / log(n)$ processori ciascuno, con tempo $T(n,p(n)) = log(n)$.

Per il terzo e ultimo ciclo for usiamo $p(n) = n$ processori con tempo $T(n,p(n)) = 3$.

I processori totali sono quindi $p(n) = n^2 / log(n)$ con tempo $T(n,p(n)) = log(n)$. L'efficienza vale $ E = frac(n log(n), n^2 / log(n) log(n)) = log(n) / n arrow.long 0 $ e nemmeno lentamente, quindi dobbiamo trovare una soluzione alternativa.

== Bitonic sort

Un algoritmo parallelo migliore è il *bitonic sort*, che avrà comunque efficienza $E arrow.long 0$ ma molto lentamente. Un altro algoritmo parallelo ottimo è quello di *Cole*, del $1988$, ma non lo vedremo, nonostante abbia $E arrow.long C eq.not 0$.

Per il bitonic sort prendiamo spunto dal merge sort, che usa la tecnica Divide et Impera.

#align(center)[
  #pseudocode-list(title: [*Merge sort*])[
    + if $abs(A) > 1$
      + $A_s = "MergeSort"(A[1], dots, A[n / 2])$
      + $A_d = "MergeSort"(A[n / 2 + 1], dots, A[n])$
      + $A = "Merge"(A_s, A_d)$
    + return $A$
  ]
]

La routine di merge effettua l'unione dei due array ordinati $A_s$ e $A_d$ scorrendoli in sequenza e mettendo i valori ordinati in $A$. Nel caso peggiore, questa routine impiega tempo $T_m (n) = n$. Il tempo di complessivo di merge sort è invece $T(n) = n log(n)$.

Possiamo sfruttare l'idea che ci dà il merge sort? Dividiamo continuamente il vettore fino ad arrivare ad un elemento. Qua devo fare il merge, se usassi un approccio parallelo avrei $log(n)-1$ passi paralleli essendo un albero. Purtroppo, il merge non è parallelizzabile, e quindi avrei sempre e comunque un tempo $T(n,p(n)) = n log(n)$.

Quando l'operazione di merge è facile? Supponiamo $A_s$ e $A_d$ ordinate con gli elementi di $A_s$ tutti minori di $A_d$. La routine di merge è facilissima: basta concatenare le due sequenze.

Cercheremo di ottenere questa situazione usando delle sequenze di numeri particolari, che sono dette * sequenze bitoniche*.

Abbiamo due operazioni fondamentali:
- *reverse*, per fare il reverse di una sequenza;
- *minmax*, che costruisce i vettori $A_min$ e $A_max$ effettuando i seguenti passi:
  - divide a metà il vettore $A$ nei vettori $A_min$ (_sx_) e $A_max$ (_dx_);
  - prese le posizioni a distanza $n/2$ in $A$, nel vettore $A_min$ viene messa la componente più piccola delle due e nel vettore $A_max$ viene messa la componente più grande delle due.

#align(center)[
  #pseudocode-list(title: [*Reverse*])[
    + for $1 lt.eq k lt.eq n/2$ par do
      + $"Swap"(A[k], A[n-k+1])$
  ]
]

Vengono utilizzati $p(n) = n/2$ processori con tempo $T(n,p(n)) = 4$.

#align(center)[
  #pseudocode-list(title: [*MinMax*])[
    + for $1 lt.eq k lt.eq n/2$ par do
      + if $A[k] > A[k + n/2]$
        + $"Swap"(A[k], A[k + n / 2])$
  ]
]

Vengono utilizzati $p(n) = n/2$ processori con tempo $T(n,p(n)) = 5$.

Vediamo ora le due sequenze numeriche che useremo per risolvere questo problema.

#definition([Sequenza unimodale])[
  Una sequenza $A$ è *unimodale* se e solo se $ exists k in {1, dots, n} bar.v A[1] > A[2] > dots > A[k] < A[k+1] < dots < A[n] $ oppure $ exists k in {1, dots, n} bar.v A[1] < A[2] < dots < A[k] > A[k+1] > dots > A[n] . $

  In poche parole, esiste un indice che mi individua un valore che mi fa da minimo/massimo e la sequenza è decrescente/crescente poi crescente/decrescente. In soldoni, il vettore *non è perfettamente ordinato*.
]

#definition([Sequenza bitonica])[
  Una sequenza $A$ è *bitonica* se e solo se esiste una permutazione ciclica di $A$ che mi dà una sequenza unimodale, ovvero se $ exists k in {1, dots, n} bar.v A[k], dots, A[n], A[1], dots, A[k - 1] $ è una sequenza unimodale.
]

Graficamente, una sequenza unimodale ha un picco _massimo/minimo_, mentre una sequenza bitonica ha due picchi:
- un _minimo+massimo_ con i valori della coda iniziale più piccoli dei valori della coda finale;
- un _massimo+minimo_ con i valori della coda iniziale più grandi dei valori della coda finale.

#v(12pt)

#figure(image("assets/07_sequenze.svg", width: 100%))

#v(12pt)

Vediamo finalmente l'algoritmo per ordinare sequenze bitoniche, ideato da *Batcher* nel $1968$.

Osserviamo che:
- una sequenza unimodale è anche bitonica, grazie alla permutazione identità;
- siano $A$ e $B$ due sequenze ordinate, allora $A dot "Reverse"(B)$ è unimodale.

Vediamo delle proprietà ora.

#lemma()[
  Sia $A$ una sequenza bitonica. Se eseguo MinMax su $A$ ottengo:
  - $A_min$ e $A_max$ bitoniche;
  - ogni elemento di $A_min$ minore di ogni elemento di $A_max$.
]

Le osservazioni e le proprietà ci suggeriscono un approccio Divide et Impera:
- MinMax divide il problema di $n$ elementi su istanze più piccole grazie alla prima parte del lemma;
- ordinando $A_min$ e $A_max$ la fusione di due sequenze ordinate avviene per concatenazione grazie alla seconda parte del lemma.

#align(center)[
  #pseudocode-list(title: [*Bitonic merge sequenziale*])[
    + $A_min bar.v A_max = "MinMax"(A)$
    + if $abs(A) > 2$
      + $"BitonicMerge"(A_min)$
      + $"BitonicMerge"(A_max)$
    + return $A$
  ]
]

Dobbiamo stare attenti a considerare *solo sequenze bitoniche*.

#theorem()[
  L'algoritmo di bitonic merge è corretto.
]

#proof()[
  Dimostriamolo per induzione su $n$.

  *Caso base*: se $n = 2$ con MinMax scambio i due elementi se sono disordinati, poi ritorno il vettore $A$ ordinato senza fare altro.

  *Passo induttivo*: supponiamo vero per $n = 2^k$, mostriamo vero per $n = 2^(k+1)$

  Calcolando MinMax su input di lunghezza $2^(k + 1)$ otteniamo due sequenze di lunghezza $2^k$, ma le sequenze di lunghezza $2^k$ bitonic merge le riesce a ordinare perfettamente per ipotesi induttiva. Grazie al lemma precedente, ogni elemento di $A_min$ è minore di ogni elemento di $A_max$, quindi il vettore $A$ è ordinato.
]

Vediamo l'implementazione parallela di bitonic merge:
- eseguiamo MinMax su input di lunghezza $ n/2^(i-1), $ partendo con $i = 1$, ottenendo di volta in volta due sequenze bitoniche $A_min$ e $A_max$ con i valori più piccoli nella prima e i valori più grandi nella seconda;
- al passo finale l'input è di lunghezza $2$, quindi fermo le esecuzioni di MinMax;
- le sequenze di $2$ elementi sono ordinate, e ora avviene una normalissima concatenazione di tutte le sequenze ottenute nei vari passi.

L'algoritmo è EREW perché lavora ogni volta su elementi diversi delle sequenze.

L'algoritmo termina i passi paralleli quando $ n/2^(i-1) = 2 arrow.long.double i = log(n) . $

Il MinMax ha costo $T(n,p(n)) = 5$ quindi $T(n,p(n)) = 5 log(n)$. Il primo passo richiede $p(n) = n/2$ processori, il secondo $p(n) = n/4 + n/4 = n/2$ processori, eccetera. Il numero di processori che andiamo ad utilizzare è quindi $p(n) = n/2$.

Se vogliamo calcolare il tempo tramite l'equazione di ricorrenza, essa è $ T(n) = cases(5 & "se" n = 2, T(n/2) + 5 quad & "altrimenti") . $

Non mettiamo costanti davanti $T(n)$ perché sto lavorando in parallelo. Il tempo che otteniamo, dopo aver risolto questa equazione di ricorrenza, è ancora $T(n,p(n)) = 5 log(n)$. L'efficienza vale $ E = frac(n log(n), n/2 5 log(n)) arrow.long C eq.not 0 . $

== Bitonic sort generico

Quello che abbiamo fatto per ora è ordinare sequenze bitoniche in modo efficiente. Vediamo, per completezza, il bitonic sort di Batcher applicato a qualunque sequenza.

#align(center)[
  #pseudocode-list(title: [*Bitonic sort generico sequenziale*])[
    + $A_min bar.v A_max = "MinMax"(A)$
    + if $abs(A) > 2$
      + $"BitSort"(A_min)$
      + $"BitSort"(A_max)$
      + $"BitMerge"(A_min dot "Reverse"(A_max))$
    + return $A$
  ]
]

#theorem()[
  L'algoritmo di bitonic sort generico sequenziale è corretto.
]

#proof()[
  Dimostriamolo per induzione su $n$.

  *Caso base*: se $n = 2$ con MinMax scambio i due elementi se sono disordinati, poi ritorno il vettore $A$ ordinato senza fare altro.

  *Passo induttivo*: supponiamo vero per $n = 2^k$, mostriamo vero per $n = 2^(k+1)$

  Calcolando MinMax su input di lunghezza $2^(k + 1)$ otteniamo due sequenze di lunghezza $2^k$, ma le sequenze di lunghezza $2^k$ bitonic sort le riesce a ordinare perfettamente per ipotesi induttiva. La chiamata finale a BitMerge avviene con una sequenza unimodale, che è al tempo stesso bitonica, ma sappiamo che BitMerge è corretto.

  Quindi il vettore $A$ è ordinato.
]

Vediamo l'implementazione parallela del bitonic sort:
- come prima, eseguiamo MinMax su input di lunghezza $ n/2^(i-1), $ partendo con $i = 1$, ottenendo di volta in volta due sequenze $A_min$ e $A_max$;
- al passo finale l'input è di lunghezza $2$, quindi fermo le esecuzioni di MinMax, visto che le sequenze di $2$ elementi sono ordinate;
- presa una coppia di sequenze $A_min$ e $A_max$, applichiamo Reverse ad $A_max$ e passiamo le due sequenze a BitMerge.

L'algoritmo è EREW perché lavoriamo sempre su dati diversi, usando letture e scritture esclusive.

Il tempo per la prima fase, ovvero la fase di applicazione di MinMax, è come quello del bitonic merge precedente, quindi mi fermo al passo $i = log(n)$. Nella seconda fase ho sempre $log(n)$ passi da moltiplicare per il costo del bitonic merge, che è $log(n)$, quindi il costo è $log^2(n)$.

Il tempo totale è quindi $T(n,p(n)) = log^2(n)$. Per quanto riguarda i processori, ne abbiamo sempre $p(n) = n/2$, utilizzati per intero ad ogni passo dell'algoritmo.

Per il tempo possiamo usare anche l'equazione di ricorrenza, che è $ T(n) = cases(5 & "se" n = 2, T(n/2) + underbracket(quad 5 quad, "MinMax") + underbracket(quad 4 quad, "Reverse") + underbracket(5 log(n), "BitMerge") quad & "altrimenti") $ ancora senza la costante sul $T(n/2)$ perché sono in un ambiente parallelo.

L'efficienza per questo algoritmo vale $ E = frac(n log(n), n/2 5 log^2(n)) = C / log(n) arrow.long 0 $ molto lentamente. Per questa sua proprietà, si preferisce usarlo su istanze molto piccole.

== Osservazioni

Un buon algoritmo sequenziale non implica un buon algoritmo parallelo: un esempio è il merge sort, come abbiamo visto durante il tentativo di parallelizzazione. Ma anche un buon algoritmo parallelo non implica un buon algoritmo sequenziale: un esempio è il bitonic sort. Vediamo perché.

Per la routine di bitonic merge, il tempo è definito dall'equazione di ricorrenza $ T_m (n) = cases(O(1) & "se" n = 2, 2 T_m (n/2) + O(n) quad & "se" n > 2) $ che, una volta risolta, ci dà tempo $T_b (n) = O(n log(n))$.

Per la routine di bitonic sort, il tempo è definito dall'equazione di ricorrenza $ T_s (n) = cases(O(1) & "se" n = 2, 2 T_s (n/2) + O(n log(n)) quad & "se" n > 2) $ che, una volta risolta, ci dà tempo $T_s (n) = O(n log^2(n))$.

Vediamo come l'algoritmo parallelo sia molto buono perché ha tempo $T(n,p(n)) = O(log^2(n))$ mentre l'algoritmo sequenziale ha tempo $T(n) = O(n log^2(n))$, che è peggio del merge sort.
