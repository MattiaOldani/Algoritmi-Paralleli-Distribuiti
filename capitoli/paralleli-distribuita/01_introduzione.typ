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

= Introduzione

Le *architetture parallele a memoria distribuita* era il paradigma utilizzato prima del multicore (_PRAM_), usato dai supercomputer più famosi come Cray, Intel Paragon, Blue Gene, Red Storm, Earth Simulator o Tianhe-2.

Queste architetture sono dei *grafi*, dove:
- i *nodi* sono dei processori, ovvero delle *RAM sequenziali* che hanno istruzioni per il calcolo e una memoria privata per effettuare calcoli; vedremo che questi nodi sono anche dei *router*;
- gli *archi* sono *reti di connessioni*.

La comunicazione avviene con le primitive *SEND* e *RECEIVE* in parallelo. *ATTENZIONE*: la comunicazione è in parallelo, ovvero le send e le receive avvengono in parallelo, ma un singolo processore lavora sequenzialmente quindi se arrivano $k$ messaggi al processore $P_i$ saranno necessarie $k$ receive.

I collegamenti sono di tipo *full-duplex*, ovvero il grafo che stiamo considerando è non orientato.

Come nella PRAM, abbiamo un *clock* centrale che scandisce il tempo per tutti i processori.

Il programma, come nelle PRAM, utilizza il *passo parallelo* con architettura SIMD.

#align(center)[
  #pseudocode-list(title: [*Passo parallelo*])[
    + for $i in II$ par do
      + $istr(k)$
  ]
]

Due sono i fattori che sono profondamente modificati:
- l'*input* non lo leggiamo più dalla memoria condivisa, come nella PRAM, ma lo dobbiamo distribuire tra i vari processori;
- l'*output* viene messo in un processore dedicato o si legge in un certo ordine tra i processori.

Le *risorse di calcolo* sono:
- *numero di processori*;
- *tempo di calcolo* e *tempo di comunicazione*, legato alla rete di connessioni.

Data l'architettura $G = (V,E)$, definiamo i seguenti *parametri di rete*:
- *grado* di $G$: definiamo $ gamma = max{rho(v) bar.v v in V} , $ dove $rho(v)$ è il numero di archi incidenti su $v$. Un valore alto permette buone comunicazioni, ma rende più difficile la realizzazione fisica;
- *diametro* di $G$: definiamo $ delta = max{d(v,w) bar.v v,w in V and v eq.not w} , $ dove $d(v,w)$ è la distanza minima tra i due vertici. Un valore basso è da preferire, ma aumenta il valore del parametro $gamma$;
- *ampiezza di bisezione* di $G$: definiamo $beta$ come il minimo numero di archi in $G$ che tolti da quest'ultimo mi dividono i nodi in circa due metà. Questa quantità rappresenta la capacità di trasferire le informazioni in $G$. Un valore alto di $beta$ alto è da preferire, ma aumenta ancora il valore del parametro $gamma$.
