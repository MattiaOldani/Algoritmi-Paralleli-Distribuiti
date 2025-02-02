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

= Introduzione

Osservazioni finali sulle PRAM:
- interesse teorico
  - processori sono uguali e alla pari
  - il tempo è strettamente legato alla computazione (comunicazione costante)
- interesse pratico
  - realizzazione fisica dei multicore

Multicore ha portato l'interesse del calcolo parallelo da ambiti scientifici ad un ambiente più ampio, tipo consumatore o informatico.

Prima del 2000 per aumentare le prestazioni si aumentava il clock con problemi:
- di assorbimento di energia (> 100W)
- di raffreddamento

Dopo il 2000 arrivano i multicore, si aumenta il grado di parallelismo con:
- clock di minor frequenza
- minor assorbimento di energia
- vantaggi sul raffreddamento

Questo porta allo sviluppo teorico in ambito di algoritmi paralleli (scrittura, riscrittura, manipolazione di software per i multicore).

== Architetture parallele a memoria distribuita

Architetture parallele a memoria distribuita erano i paradigmi usati prima del multicore, usato dai supercomputer (anni 60 cray e intel paragon, mentre attuali cray, blue gene, red storm, earth simulator, tianhe-2)

Sono supercomputer a memoria distribuita, ovvero sono grafi con nodi processori e archi reti di connessioni. Alle PRAM manca la memoria condivisa.

I processori sono RAM sequenziali con:
- elementi di calcolo, hanno istruzioni per il calcolo e la loro memoria privata
- router, hanno istruzioni per la comunicazione di send e receive

La comunicazione avviene in parallelo, ma se $p_1, dots, p_k$ mandano contemporaneamente dati a $p$ essi sono fatti in modo simultaneo, ma $p$ lavora sequenzialmente quindi deve fare $k$ receive, quindi servono $k+1$ passi per la comunicazione (send parallela e $k$ receive).

I collegamenti sono di tipo full-duplex, ovvero comunicazione diretta, archi non orientati. Se c'è collegamento diretto la comunicazione costa $2$ passi (send e receive).

Abbiamo anche un clock centrale che scandisce il tempo per tutti i processori.

Il programma, come nelle PRAM, è un PAR DO, quindi $ &"for k in I par do" \ &quad "istruzione k" $ con anche send e receive (architettura SIMD single instruction multiple data)

Cambiano input e output: non abbiamo più la memoria condivisa come la PRAM, quindi l'input viene distribuito tra i processori, mentre l'output o viene messo in un processore dedicato o si legge in un certo ordine tra i vari processori.

Le risorse di calcolo sono:
- numero di processori: può essere la lunghezza dell'input ma ci sono tecniche per abbassare il numero
- tempo, dato da:
  - tempo di calcolo
  - tempo di comunicazione, può essere rilevante ed è legato alla rete di connessioni

Abbiamo i seguenti parametri di rete: data l'architettura $G = (V,E)$ definiamo:
- grado di $G$: per ogni vertice calcoliamo $ gamma = max{rho(v) bar.v v in V} $ dove $rho(v)$ è il numero di archi incidenti su $v$; un valore alto permette buone comunicazioni ma rende più difficile la realizzazione fisica
- diametro di $G$: definiamo $ delta = max{d(v,w) bar.v v,w in V and v eq.not w} $ come il massimo tra tutte le distanze minime da $v$ e $w$; valori bassi di $delta$ sono da preferire, ma aumentano il parametro $gamma$
- ampiezza di bisezione di $G$: sia $beta$ il minimo numero di archi in $G$ che tolti mi dividono i nodi in circa due metà; esso rappresenta la capacità di trasferire le informazioni in $G$, ancora una volta $beta$ alto si preferisce ma incrementa $gamma$
