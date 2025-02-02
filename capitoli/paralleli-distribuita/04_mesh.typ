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

= Architettura MESH

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

Riprendiamo ancora la mesh

Riduciamo i processori da $n$ a $p$, ogni processore calcola il max tra $n/p$ dati in tempo $O(n/p)$. Poi, si attiva l'algoritmo di prima sulla griglia $sqrt(p) times sqrt(p)$, che viene eseguito però in $O(sqrt(p))$

Il tempo totale è $T = n/p + sqrt(p)$

Il denominatore invece è $ p (n/p + sqrt(p)) = n + p^(3/2) $

Vogliamo un denominatore $n$ per avere una costante per l'efficienza, quindi scelgo $p^(3/2) = n$ ovvero $ p = n^(2/3) $

Il tempo totale diventa quindi $ n/p + sqrt(p) = n^(1 - 2/3) + sqrt(n^(2/3)) = n^(1/3) + n^(1/2 dot 2/3) = root(3,x) + root(3,x) = O(root(3,x)) $

Otteniamo efficienza ok

Limite teorico dobbiamo rifare i conti: con $sqrt(p)$ il limite è $Omega(sqrt(p))$ quindi $Omega(root(3,n))$ ma noi siamo esattamente qua quindi tanta tanta roba

== Ordinamento LS3

Ricercatori anni 80

Ricorsivo con divide et impera. Non ordiniamo più a serpente.

Sia $M$ il quadrato dei processori:
- dividi: divido in 4 quadrati $M_1, M_2, M_3, M_4$ sx alto dx alto sx basso dx basso (italiano) di dimensione $m/2$ con $m = sqrt(n)$
- ordina: faccio l'ordinamento a serpente in parallelo
- fondi: mi arrivano 4 matrici, le fondo dando la matrice totalmente ordinata

Vediamo LS3 parallelo

#align(center)[
  #pseudocode-list(title: [LS3sort])[
    + if $abs(M) == 1$
      + return $M$
    + LS3sort(M_1)
    + LS3sort(M_2)
    + LS3sort(M_3)
    + LS3sort(M_4)
    + LS3merge(...)
  ]
]

Ci serve vedere anche la merge

Ci servono shuffle e odd/even. Data una riga i della mesh, essa è un array lineare di processori. Su questa riga facciamo lo shuffle. Lo shuffle viene fatto su M, formato dalle matrici M_k ordinate. Quindi lo shuffle viene fatto sulla riga di $M$.

Lo shuffle intramezzava prima metà con la seconda metà, cioè metteva vicini gli elementi con lo stesso indice delle due righe della matrice.

Dopo lo shuffle devo eseguire ODD-EVEN tra due colonne adiacenti i e i+1. Vogliamo vederlo come array lineare: lo costruiamo a serpente. Su questo facciamo ODD-EVEN quindi ordiniamo, sono $2 sqrt(n)$ e quindi avremo quel numero di round

#align(center)[
  #pseudocode-list(title: [LS3merge])[
    + for $i = 1$ to $sqrt(n)$ par do
      + SHUFFLE(i)
    + for $i = 1$ to $sqrt(n) / 2$ par do
      + ODD-EVEN(2i-1, 2i)
    + esegui i primi $2 sqrt(n)$ passi di ODD-EVEN sull'intera mesh a serpente
  ]
]

Il tempo per sta roba è $O(sqrt(n))$ per lo shuffle, $O(sqrt(n))$ per ODD-EVEN, e ancora $O(sqrt(n))$ per l'ultima esecuzione, quindi il tempo per la merge è $T_m (n) = h sqrt(n)$

Risolviamo l'equazione di ricorrenza per sto schifo: $ T(n) = cases(1 "se" n = 1, T(n/4) + h sqrt(n) "altrimenti") $

Ma allora $ T(n) = T(n/4) + h sqrt(n) = T(n/4^2) + h sqrt(n/4) + h sqrt(n) = T(n/4^3) + h sqrt(n/4^2) + h sqrt(n/4) + h sqrt(n) = dots = sum_(i=0)^(log_4(n) - 1) h sqrt(n/4^i) + 1 = h sqrt(n) sum_(i=0)^(log_4(n) - 1) sqrt(1/4^i) + 1 = h sqrt(n) sum_(i=0)^(log_2(n) / log_4(n) - 1) 1/2^i + 1 = h sqrt(n) sum_(i=0)^(log(n) / 2 - 1) (1/2)^i + 1 = h sqrt(n) (frac(1 - (1/2)^(log(n)/2 - 1 + 1), 1/2)) + 1 = 2 h sqrt(n) (1 - 1/sqrt(n)) + 1 = O(sqrt(n)) . $

Se aggiungo un 4 ci esce $n sqrt(n)$ per il sequenziale (peggio del merge sort)

Processori sono $p(n) = n$ e il tempo è $T(n) = O(sqrt(n))$ quindi $ E = frac(n log(n), n sqrt(n)) arrow.long 0 $ che non ci piace

Possiamo migliorare riducendo i processori, ma non lo vedremo

Con una versione del bitonic sort su mesh usa processori $O(log^2(n))$ e tempo $T(n) = O(n / log(n))$ che è efficiente, ma come tempo è peggiore di LS3.
