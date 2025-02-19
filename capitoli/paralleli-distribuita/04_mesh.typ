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

= Architettura MESH

Le *MESH* sono un'architettura parallela a memoria distribuita che rappresenta i processori come un array bidimensionale a griglia. Avendo a disposizione $n$ processori, la MESH è un quadrato $m times m$ con $m = sqrt(n)$. Se $n$ non è un quadrato perfetto allora prendiamo $m = (floor(sqrt(n)) + 1)^2$, che per $n gt.eq 6$ ci dà un valore $lt.eq 2n$, che ci va molto bene.

I *parametri* di rete di questa architettura sono:
- *grado* $gamma = 4$;
- *diametro* $delta = 2 sqrt(n)$
- *ampiezza di bisezione* $beta tilde sqrt(n)$ in base alla parità di $m$.

#v(12pt)

#figure(image("assets/04_mesh.svg", width: 50%))

#v(12pt)

I nostri lower bound diventano:
- $Omega(sqrt(n))$ per *Max*;
- $Omega(sqrt(n))$ per *Ordinamento*.

== Max

L'idea per un algoritmo parallelo è quella di usare la MESH come se fosse un array lineare, andando _"a serpentello"_ nelle varie celle, ma un array lineare ha come tempo minimo $n$ e noi invece abbiamo $sqrt(n)$, quindi questa idea è cestinata immediatamente.

Usiamo un algoritmo *righe-colonna*: abbiamo a disposizione tante connessioni, perché non usarle?

Consideriamo ogni riga della MESH come se fosse un array lineare di $sqrt(n)$ processori. Il massimo di ogni riga verrà messo nell'ultimo processore, e sulla colonna formata dai _"processori massimi"_ eseguiamo ancora un'esecuzione di Max su array lineari.

#align(center)[
  #pseudocode-list(title: [*Max righe-colonna*])[
    + for $i = 1$ to $m$ par do
      + $"Max"(P_(i 1), dots, P_(i m))$
    + $"Max"(P_(1 m), dots, P_(m m))$
  ]
]

Il tempo, per entrambe le parti, è $T(n,p(n)) = O(sqrt(n))$. L'efficienza purtroppo è $ E = frac(n, n sqrt(n)) arrow.long 0 . $

Riduciamo il numero di processori con il *principio di Wyllie* da $n$ a $p$, dove ognuno di questi calcola il massimo di $n/p$ dati in tempo $O(n/p)$. Poi, si attiva l'algoritmo di prima sulla MESH $sqrt(p) times sqrt(p)$, che viene eseguito però in un tempo minore, ovvero $T(n,p(n)) = O(sqrt(p))$.

Il tempo totale di questo nuovo algoritmo è è $T(n,p(n)) = n/p + sqrt(p)$. L'efficienza vale $ E = frac(n, p (n/p + sqrt(p))) = frac(n, n + underbracket(p sqrt(p), n)) = C eq.not 0 . $

Per avere questa efficienza scelgo $p sqrt(p) = n$, ovvero $p = n^(2/3)$.

Con questa scelta di $p$ il tempo totale diventa $T(n,p(n)) = O(root(3,n))$. E questo valore è ottimo: usando una MESH di dimensione $sqrt(p)$ il limite teorico per Max è $sqrt(p) = sqrt(n^(2/3)) = root(3,n)$, che è esattamente il valore che abbiamo ottenuto noi, quindi siamo soddisfatti.

== Ordinamento

L'algoritmo di *ordinamento LS3* deve il suo nome a due ricercatori degli anni $'80$.

L'algoritmo che utilizziamo è ricorsivo con *Divide et Impera*

Sia $M$ il quadrato dei processori. L'algoritmo procede come segue:
- *dividi*: $M$ viene diviso in 4 quadrati $M_1 bar.v M_2 bar.v M_3 bar.v M_4$ di dimensione $m/2$ con $m = sqrt(n)$. Questi sono ottenuti da $M$ dividendolo come se fossero i quadranti di un piano cartesiano, ovvero $ mat(M_1, M_2; M_3, M_4) ; $
- *ordina*: i quadrati $M_i$ vengono ordinati _"a serpentello"_ in parallelo;
- *fondi*: i quadrati $M_i$ vengono rimessi nelle loro posizioni originali.

#align(center)[
  #pseudocode-list(title: [*LS3sort*])[
    + if $abs(M) == 1$
      + return $M$
    + else
      + $"LS3sort"(M_1)$
      + $"LS3sort"(M_2)$
      + $"LS3sort"(M_3)$
      + $"LS3sort"(M_4)$
      + $"LS3merge"(M_1, M_2, M_3, M_4)$
  ]
]

Per implementare questo algoritmo ci servono shuffle e ODD/EVEN.

Data una riga $i$ della MESH, essa è un *array lineare* di processori. Su questa riga eseguiamo lo *shuffle*. Questa operazione alterna elementi della matrice $M_1$ con elementi della matrice $M_2$ (_sopra_) ed elementi della matrice $M_3$ con elementi della matrice $M_4$ (_sotto_).

Dopo lo shuffle devo eseguire *ODD/EVEN* tra due colonne adiacenti $i$ e $i+1$. Prendiamo le due colonne assieme e creiamo un *array lineare* andando _"a serpentello"_. Il numero di round di questo algoritmo è uguale alla grandezza di questo array, che è $2 sqrt(n)$.

#align(center)[
  #pseudocode-list(title: [*LS3merge*])[
    + for $i = 1$ to $sqrt(n)$ par do
      + $"SHUFFLE"(i)$
    + for $i = 1$ to $sqrt(n) / 2$ par do
      + $"OddEven"(2i-1, 2i)$
    + Esegui i primi $2 sqrt(n)$ passi di ODD/EVEN sull'intera mesh a serpente
  ]
]

Il tempo per questo algoritmo è:
- $O(sqrt(n))$ per lo shuffle;
- $O(sqrt(n))$ per ODD-EVEN;
- $O(sqrt(n))$ per l'ultima esecuzione.

Ma allora tempo totale della merge è $T_m (n) = h sqrt(n)$

Risolviamo l'equazione di ricorrenza per sto schifo: $ T(n) = cases(1 & "se" n = 1, T(n/4) + h sqrt(n) quad & 6 "altrimenti") . $

Ma allora $ T(n) &= T(n/4) + h sqrt(n) = T(n/4^2) + h sqrt(n/4) + h sqrt(n) = T(n/4^3) + h sqrt(n/4^2) + h sqrt(n/4) + h sqrt(n) = \ &= "mi fermo quando" M_i "è grande 4" = \ &= sum_(i=0)^(log_4(n) - 1) h sqrt(n/4^i) + 1 = \ &= h sqrt(n) sum_(i=0)^(log_4(n) - 1) sqrt(1/4^i) + 1 = \ &= h sqrt(n) sum_(i=0)^(frac(log_2(n),log_2(4)) - 1) 1/2^i + 1 = \ &= h sqrt(n) sum_(i=0)^(log(n) / 2 - 1) (1/2)^i + 1 = \ &= h sqrt(n) (frac(1 - (1/2)^(log(n)/2 - 1 + 1), 1/2)) + 1 = 2 h sqrt(n) (1 - 1/sqrt(n)) + 1 = O(sqrt(n)) . $

Nel caso sequenziale, aggiungendo un $4$ all'equazione di ricorrenza, otteniamo tempo $T(n) = n sqrt(n)$, un tempo peggiore del merge sort.

Per il caso parallelo, abbiamo $p(n) = n$ processori con tempo $T(n,p(n)) = O(sqrt(n))$. L'efficienza è $ E = frac(n log(n), n sqrt(n)) arrow.long 0 . $

Non ci piace molto come valore, possiamo migliorare l'efficienza riducendo i processori, ma non lo vedremo. Non vedremo nemmeno una versione del bitonic sort (_bentornato tra noi_) su MESH che usa $p(n) = O(log^2(n))$ processori in tempo $T(n,p(n)) = O(n / log(n))$ con una buonissima efficienza, ma vediamo che come tempo è peggiore di LS3.
