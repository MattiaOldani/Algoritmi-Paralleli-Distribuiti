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


= Lezione 12

Due operazioni fondamentali:
- REV per fare il reverse *in parallelo*;
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
- siano $A,B$ due sequenze ordinare, allora $A dot "REV"(B)$ è unimodale.

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
- minmax suddivide il problema si $n$ elementi su istanze più piccole grazie alla prima parte;
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
