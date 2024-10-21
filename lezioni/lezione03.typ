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


= Lezione 03

== Architetture

=== Memoria condivisa

L'architettura a *memoria condivisa* utilizza una memoria centrale che permette lo scambio di informazioni tra un numero $n$ di processori $P_i$, ognuno dei quali possiede anche una "memoria personale", formata dai registri.

#v(12pt)

#figure(
  image("assets/03_memoria-condivisa.svg", width: 50%),
)

#v(12pt)

Un *clock* centrale e comune coordina tutti i processori, che comunicano attraverso la memoria centrale in tempo costante $O(1)$, permettendo quindi una forte parallelizzazione.

=== Memoria distribuita

L'architettura a *memoria distribuita* utilizza una rete di interconnesione centrale che permette lo scambio di informazioni tra un numero $n$ di processori $P_i$, ognuno dei quali possiede anche una "memoria personale", formata dai registri.

#v(12pt)

#figure(
  image("assets/03_memoria-distribuita.svg", width: 50%),
)

#v(12pt)

Un *clock* centrale e comune coordina tutti i processori, che comunicano attraverso la rete di interconnesione in un tempo che dipende dalla distanza tra i processori.

=== Modello PRAM

==== Definizione

Il *modello PRAM* (_Parallel RAM_) utilizza una memoria $M$ formata da registri $M[i]$ e una serie di processori $P_i$ che si interfacciano con essa. Ogni processore $P_i$ è una *RAM sequenziale*, ovvero contiene una unità di calcolo e una serie di registri $R[i]$.

La comunicazione avviene con la memoria centrale tramite due primitive che lavorano in tempo costante $O(1)$:
- `LOAD R[dst] M[src]` per copiare nel registro `dst` il valore contenuto in memoria nella cella `src`;
- `STORE R[src] M[dst]` per copiare in memoria nella cella `dst` il valore contenuto nel registro `src`.

Le operazioni di ogni processore avvengono invece in locale, cioè con i dati della propria memoria privata. Il tempo di ogni processore $P_i$ è scandito da un clock centrale, che fa eseguire ad ogni processore la "stessa istruzione" $text("istruzione")_i$.

Infatti, andiamo a definire il *passo parallelo* nel seguente modo

#align(center)[
  #pseudocode-list()[
    + for $i in II$ par do:
      + $istr(i)$
  ]
]

In poche parole, tutti i processori con indice in $II$ eseguono l'$i$-esima istruzione, altrimenti eseguono una nop.

==== Modelli per le istruzioni

L'istruzione eseguita dipende dal tipo di architettura:
- *SIMD* (Single Instruction Multiple Data) indica l'esecuzione della stessa istruzione ma su dati diversi;
- *MIMD* (Multiple Instruction Multiple Data) indica l'esecuzione di istruzioni diverse sempre su dati diversi.

==== Modelli per l'accesso alla memoria

Abbiamo diverse architetture anche per quanto riguarda l'accesso alla memoria:
- *EREW* (Exclusive Read Exclusive Write) indica una memoria con lettura e scrittura esclusive;
- *CREW* (Concurrent Read Exclusive Write) indica una memoria con lettura simultanea e scrittura esclusiva;
- *CRCW* (Concurrent Read Concurrent Write) indica una memoria con lettura e scrittura simultanee.

Per quanto riguarda la scrittura simultanea abbiamo diverse modalità:
- *common*: i processori possono scrivere solo se scrivono lo stesso dato;
- *random*: si sceglie un processore $Pi$ a caso;
- *max/min*: si sceglie il processore $Pi$ con il dato massimo/minimo;
- *priority*: si sceglie il processore $P_i$ con priorità maggiore.

// Sistema qua
La politica EREW è la più semplice, ma si può dimostrare che $ "Algo(EREW)" arrow.long.double.l.r "Algo(CREW)" arrow.long.double.l.r "Algo(CRCW)" . $

Le implicazioni da sinistra verso destra sono "immediate", mentre le implicazioni opposte necessitano di alcune trasformazioni.

==== Risorse di calcolo

Essendo i singoli processori delle RAM, abbiamo ancora le risorse di tempo $t(n)$ e spazio $s(n)$, ma dobbiamo aggiungere:
- $p(n)$ numero di processori richiesti su input di lunghezza $n$ nel caso peggiore;
- $T(n, p(n))$ tempo richiesto su input di lunghezza $n$ e $p(n)$ processori nel caso peggiore.

Notiamo come $T(n,1)$ rappresenta il tempo sequenziale $t(n)$.

Vediamo la struttura di un programma in PRAM.

#v(12pt)

#figure(
  image("assets/03_pram.svg", width: 60%),
)

#v(12pt)

Ogni processore $p_i$ esegue una serie di istruzioni nel passo parallelo, che possono essere più o meno in base al processore e al numero $p(n)$ di processori.

Indichiamo con $t_i^((j)) (n)$ il tempo che impiega il processore $j$-esimo per eseguire l'$i$-esimo passo parallelo su un input lungo $n$.

Quello che vogliamo ricavare è il tempo complessivo del passo parallelo: visto che dobbiamo aspettare che ogni processore finisca il proprio passo, calcoliamo il tempo di esecuzione $t_i (n)$ dell'$i$-esimo passo parallelo come $ t_i (n) = max {t_i^((j)) (n) bar.v 1 lt.eq j lt.eq p(n)} . $

Banalmente, il tempo complessivo di esecuzione del programma è la somma di tutti i tempi dei passi paralleli, quindi $ T(n, p(n)) = sum_(i=1)^(k(n)) t_i (n) . $

Notiamo subito come:
- $T$ dipende da $k(n)$, ovvero dal numero di passi;
- $T$ dipende dalla dimensione dell'input;
- $T$ diepnde da $p(n)$ perché diminuire/aumentare i processori causa un aumento/diminuzione dei tempi dei passi paralleli.
