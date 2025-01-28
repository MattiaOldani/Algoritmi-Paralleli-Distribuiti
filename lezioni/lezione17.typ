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


= Lezione 17

La minmax ha 4 come costo del passo parallelo.

Ordinamento ha in input $A[1], dots, A[n]$ assegnati ai processori $P_1, dots, P_n$ e in output voglio cont(P_1) < dots < cont(P_n)

Diamo un algoritmo test/swap obliovius descritto da una SN, si chiama ODD/EVEN sorting network.

Abbiamo una colonna di confrontatori dispari (sopra è su un dispari) seguita una colonna di confrontatori pari. Una colonna si chiama round perché è un passo parallelo. Alterno per $n$ volte questi confrontatori.

Per la correttezza di ODD/EVEN usiamo il principio 0/1, ovvero $ {0,1}^n arrow.long.squiggly "ODD/EVEN" arrow.long.squiggly 0^j 1^e quad bar.v quad j + e = n $ a patto di fare esattamente $n$ round.

Ogni $1$ deve scendere di $n-e=j$ posizioni. Contiamo gli uni a partire da 1 a partire dal basso. Vediamo quanto ci mettono a scednere di $j$ posizioni. Notiamo che $i$ ha $i$ ritardi e poi scende di $j$ posizioni. Quindi il primo uno che abbiamo ci mette $j + i$, ma $i$ è esattamente il numero di 1 dell'input, è il ritardo.

Regola: l'$i$-esimo uno dal basso impiega $n - e + i$ passi per posizionarsi correttamente.In generale è un al più.

Dato che $i lt.eq e$ si ottiene $ n - e + underbracket(e, i "di prima") = n . $

Quindi $n$ passi sono necessari (visto dall'input) e sufficienti.

Implementazione sequenziale è $n n/2 approx n^2$

In parallelo usiamo Haberman del 1972

Abbiamo $n$ passi paralleli o round di confrontatori paralleli con minmax(k,k+1)

#align(center)[
  #pseudocode-list()[
    + for $i = 1$ to $n$
      + for $k in {2t - (i % 2) bar.v 1 lt.eq t lt.eq n/2}$ par do
        + minmax(k,k+1)
  ]
]

Il tempo è $4n = O(n)$ mentre efficienza è $ frac(n log(n), n n) arrow.long 0 $ non va bene riduco i processori

Osservazione: per $n$ processori in un array lineare l'ordinamento vuole tempo $Omega(frac(n, 2 beta))$ e qui $beta = 1$ quindi ci mettevo $n$, non va bene

Riduco i processori a $p$ quindi ognuno prende $n/p$ dati e li ordina in sequenza in un tempo $O(n/p log(n/p))$

L'algoritmo è una versione che non usa minmax ma merge-split: avviene tra due processori contigui. Essa fa:
- processore di sinistra spedisce $n/p$ dati ordinati al processore di destra in un tempo $O(n/p)$
- il processore di destra riceve e fonde i nuovi $n/p$ dati con i suoi $n/p$ ordinati (operazione di merge) in tempo $O(n/p)$
- il processore di destra invia i dati più piccoli $n/p$ al processore di sinistra in un tempo $O(n/p)$ (operazione di split)

#align(center)[
  #pseudocode-list()[
    + for $i = 1$ to $p$
      + for $k in {2t - (i % 2) bar.v 1 lt.eq t lt.eq p/2}$ par do
        + merge-split(k,k+1)
  ]
]

Ogni primitiva di merge-split viene ripetuta $p$ volte

Il tempo parallelo è $n/p log(n/p) + p n/p = O(n)$. Il denominatore è $p (n/p log(n/p) + n) = n log(n/p) + n p$ e noi vogliamo che sia $n log(n)$ per avere una frazione uguale. Quindi prendiamo $p = log(n)$. Efficienza quindi $E arrow.long C eq.not 0$

Osserviamo come il tempo sia rimasto $O(n)$ ma abbiamo abbassato il tempo parallelo. Ciò si spiega in quanto la riduzione dei processori agisce sul diametro e non sull'ampiezza di bisezione, che rimane sempre $beta = 1$.

Possiamo migliorare questi costi

== Architettura MESH

Usate dai supercomputer, array bidimensionale ovvero griglia di processori

Avendo $n$ processori abbiamo un quadrato $m times m$ con $m = sqrt(n)$ disposti come una matrice. Se $n$ non è un quadrato perfetto prendiamo $ (floor(sqrt(n)) + 1)^2 lt.eq 2n $ per $n gt.eq 6$ quindi va bene lo stesso

Parametri di rete:
- $gamma = 4$ (secondo lei è $rho$)
- $delta = 2 sqrt(n)$ perché devo fare la scala
- $beta tilde sqrt(n)$ (due diversi tagli)

I nostri lower bound diventano $Omega(sqrt(n))$ per max e $Omega(sqrt(n))$ per l'ordinamento, quindi tanta roba

Vediamo il massimo: idea immediata se usiamo la mesh come array lineare di $n$ processori, facendo tipo serpentello, ma si ottiene $Omega(n)$ per il tempo contro $Omega(sqrt(n))$ che abbiamo adesso in una mesh

Pensiamo ad un algoritmo righe-colonna, ovvero non penso al serpentello ma anche ad alte connessioni. Ogni riga è un array lineare di $sqrt(n)$ processori, in più anche l'ultima colonna è un array lineare di $sqrt(n)$ processori. Sposto i massimi di ogni riga in fondo e poi max dei massimi.

#align(center)[
  #pseudocode-list()[
    + $m = sqrt(n)$
    + for $i = 1$ to $m$ par do
      + MAX(Pi1, Pi2, dots, Pim)
      - in Pim ho il massimo ora
    + MAX(P1m, P2m, dots, Pmm)
  ]
]

Tempo per la parte 1 è $sqrt(n)$, idem per la seconda parte, quindi eseguo in tempo $O(sqrt(n))$ quindi siamo soddisfatti. Efficienza purtroppo è $ frac(n, n sqrt(n)) arrow.long 0 $ quindi riduciamo i processori

Passiamo da $n$ a $p$, ma andiamo avanti prossima volta
