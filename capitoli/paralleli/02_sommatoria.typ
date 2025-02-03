// Setup

#import "../alias.typ": *

#import "@preview/fletcher:0.5.4": diagram, node, edge

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

= Sommatoria

Cerchiamo un algoritmo parallelo per il calcolo di una *sommatoria*.

Il problema:
- prende in *input* una serie di numeri $M[1], dots, M[n]$;
- restituisce in *output*, dentro il registro $M[n]$, la somma dei valori $ M[1], dots, M[n]$.

Un buon algoritmo sequenziale è quello che utilizza $M[n]$ come *accumulatore*, lavorando in tempo $ T(n,1) = n-1 $ senza usare della memoria aggiuntiva.

#align(center)[
  #pseudocode-list(title: [*Sommatoria sequenziale*])[
    + for $i = 1$ to $n$ do
      + $M[n] = M[n] + M[i]$
    + *output* $M[n]$
  ]
]

== Prima versione

Un primo approccio parallelo potrebbe essere quello di far eseguire ad ogni processore una somma.

#v(12pt)

#figure(image("assets/02_sommatoria-naive.svg", width: 60%))

#v(12pt)

Usiamo $n-1$ processori, ma abbiamo dei problemi:
- l'albero che otteniamo ha altezza $n-1$;
- ogni processore deve aspettare la somma del processore precedente, quindi $T(n, n-1) = n-1$.

L'efficienza che otteniamo è $ E(n, n-1) = frac(n-1, (n-1) (n-1)) arrow.long 0 . $

Una soluzione migliore considera la _proprietà associativa_ della somma per effettuare delle somme $2$ a $2$ e abbassare il tempo.

#v(12pt)

#figure(image("assets/02_sommatoria-mid.svg"))

#v(12pt)

Quello che otteniamo è un albero binario, sempre con $n-1$ processori ma altezza dell'albero logaritmica in $n$. Il risultato di ogni somma viene scritto nella cella di indice maggiore, quindi vediamo la rappresentazione corretta.

#v(12pt)

#figure(image("assets/02_sommatoria-sium.svg"))

#v(12pt)

Quello che possiamo fare è sommare, ad ogni passo $i$, gli elementi che sono a distanza $i$: partiamo sommando elementi adiacenti a distanza $1$, poi $2$, fino a sommare al passo $log(n)$ gli ultimi due elementi a distanza $n/2$.

#align(center)[
  #pseudocode-list(title: [*Sommatoria parallela*])[
    + for $i = 1$ to $log(n)$ do
      + for $k = 1$ to $frac(n,2^i)$ par do
        + $M[2^i k] = M[2^i k] + M[2^i k - 2^(i-1)]$
    + return $M[n]$
  ]
]

#theorem()[
  L'algoritmo di sommatoria parallela è EREW.
]

#proof[
  Dobbiamo mostrare che al passo parallelo $i$ il processore $a$, che utilizza $2^i a$ e $2^i a - 2^(i-1)$, legge e scrive celle di memoria diverse rispetto a quelle usate dal processore $b$, che utilizza $2^i b$ e $2^i b - 2^(i-1)$.

  Mostriamo prima che $2^i a eq.not 2^i b$, ma questo è banale se $a eq.not b$.

  Mostriamo infine che $2^i a eq.not 2^i b - 2^(i-1)$. Supponiamo per assurdo che siano uguali, allora $ 2 dot frac(2^i a, 2^i) = 2 dot frac(2^i b - 2^(i-1), 2^i) arrow.long.double 2a = 2b -1 arrow.long.double a = frac(2b - 1, 2) $ ma questo è assurdo perché $a in NN$.
]

#theorem()[
  L'algoritmo di sommatoria parallela è corretto.
]

#proof[
  Per dimostrare che l'algoritmo è corretto mostriamo che al passo parallelo $i$, nella cella $2^i k$, ho i $2^i - 1$ valori precedenti sommati a $M[2^i k]$, ovvero che $ M[2^i k] = M[2^i k] + dots + M[2^i (k-1) + 1] . $

  Notiamo che se $i = log_2(n)$ allora ho un solo processore attivo, quindi abbiamo $k = 1$ e otteniamo la definizione di sommatoria, ovvero $ M[n] = M[n] + dots + M[1] . $

  Dimostriamo per induzione.

  *Passo base*: se $i = 1$ allora $M[2k] = M[2k] + M[2k-1]$.

  *Passo induttivo*: supponiamo sia vero per $i-1$, dimostriamo che vale per $i$.

  Sappiamo che al generico passo $i$ eseguiamo l'operazione $M[2^i k] = M[2^i k] + M[2^i k - 2^(i-1)]$.

  Andiamo a riscrivere i due fattori della somma in un modo a noi più comodo.

  Il primo fattore è $ M[2^i k] = M[2^(i-1) dot (2k)] =_("HP-I") M[2^(i-1) dot (2k)] + dots + M[2^(i-1) dot (2k - 1) + 1] . $

  Il secondo fattore è $ M[2^i k - 2^(i-1)] = M[2^(i-1) (2k - 1)] =_("HP-I") M[2^(i-1) (2k - 1)] + dots + M[2^(i-1) (2k - 2) + 1] . $

  Notiamo ora che il primo e il secondo fattore sono contigui: infatti, l'ultima cella del primo fattore è un indice superiore rispetto alla prima cella del secondo fattore. Inoltre, l'ultima cella del secondo fattore può essere riscritta come $ M[2^i (k - 1) + 1], $ quindi abbiamo ottenuto esattamente quello che volevamo dimostrare.
]

Se $n$ è potenza di $2$ usiamo $p(n) = n/2$ processori con un tempo $T(n, n/2) = 4 log(n)$, dovuto alle microistruzioni che vengono fatte in ogni passo parallelo.

Se $n$ non è potenza di $2$ dobbiamo _"allungare"_ il nostro input fino a raggiungere una dimensione uguale alla potenza di $2$ più vicina, aggiungendo degli zeri in coda, ma questo non va ad intaccare le prestazioni perché la nuova dimensione è limitata da $2n$. Infatti, con lunghezza $2n$ usiamo $p(n) = frac(2n,2) = n$ processori e abbiamo tempo $T(n, n) = 4 log(2n) lt.eq 5 log(n)$.

In poche parole, in entrambi i casi abbiamo $p(n) = O(n)$ e $T(n, p(n)) = O(log(n))$.

Se però calcoliamo l'efficienza otteniamo $ E(n,n) = frac(n-1, 5n log(n)) arrow.long 0 , $ quindi dobbiamo trovare una soluzione migliore, anche se $E$ tende a $0$ lentamente.

== Seconda versione [ottimizzata]

Usiamo il *principio di Wyllie*: vogliamo arrivare ad avere $E arrow.long C eq.not 0$, diminuendo il numero di processori utilizzati. Andiamo quindi ad utilizzare $p$ processori raggruppando i numeri presenti in $M$ in gruppi grandi $Delta = n / p$, ognuno associato ad un processore.

Al primo passo dell'algoritmo ogni processore esegue la somma sequenziale dei $Delta$ valori contenuti nel proprio gruppo, ovvero $M[k Delta] = M[k Delta] + dots + M[(k-1) Delta + 1]$. Successivamente, si esegue l'algoritmo sommatoria proposto prima sulle celle di memoria $M[Delta], M[2 Delta], dots, M[p Delta]$, e in quest'ultima viene inserito il risultato finale.

In questa versione ottimizzata usiamo $p(n) = p$ processori con un tempo $T(n, p)$ formato dal primo passo parallelo _"di ottimizzazione"_ sommato al tempo di sommatoria, quindi $ T(n,p) = n / p + 5 log(p) . $

Andiamo a calcolare l'efficienza $ E = frac(n-1, p dot (n / p + 5 log(p))) = frac(n-1, n + underbracket(5 p log(p), n)) approx n / (2n) = 1 / 2 eq.not 0 . $

Per arrivare ad avere questa efficienza che tanto volevamo, dobbiamo imporre $5 p log(p) = n$, quindi $ p = frac(n, 5 log(n)) . $

Con questa assunzione riusciamo ad ottenere un tempo $ T(n, p(n)) lt.eq 10 log(n) . $

Diamo un *lower bound*: sommatoria possiamo visualizzarlo usando un albero binario, dove le foglie sono i dati di input e i livelli sono i passi paralleli. Il livello con più nodi dà il numero di processori e l'altezza dell'albero dà il tempo dell'algoritmo. Se abbiamo altezza $h$, abbiamo massimo $2^h$ foglie, quindi $ "foglie" = n lt.eq 2^h arrow.long.double h gt.eq log(n), $ quindi ho sempre tempo logaritmico.

== Operazione iterata

La sommatoria può essere uno schema per altri problemi.

L'*operazione iterata* è una operazione associativa *OP* sulla quale definiamo un problema che:
- prende in *input* una serie di valori $M[1], dots, M[n]$;
- restituisce in *output*, dentro il registro $M[n]$, l'operazione *OP* calcolata su tutti gli $M[i]$.

Abbiamo visto che sommatoria ammette soluzioni efficienti con $p(n) = O(n/log(n))$ processori utilizzati e tempo $T(n,p(n)) = O(log(n))$.

Con modelli PRAM più potenti (_non EREW_) possiamo ottenere un tempo costante per AND e OR.

Supponiamo una CRCW-PRAM e vediamo il problema *AND-iterato*, ovvero $ M[n] = and.big_i M[i] . $

Come detto poco fa, il tempo è costante perché la PRAM è più potente.

#align(center)[
  #pseudocode-list(title: [$bold(and.big)$*-iterato*])[
    + for $1 lt.eq k lt.eq n$ par do
      + if $M[k] = 0$ then
        + $M[n] = 0$
  ]
]

Serve CW con *politica common*, quindi scrivono i processori se e solo se il dato da scrivere è uguale per tutti. In realtà, anche le altre politiche (_random o priority_) vanno bene.

In questo specifico caso abbiamo $p(n) = n$ processori e tempo $T(n,n) = 3$. Calcoliamo l'efficienza di questo problema come $ E = (n-1)/(3n) arrow.long 1/3 . $

Per il problema *OR-iterato* vale la stessa cosa, basta modificare leggermente il codice proposto.
