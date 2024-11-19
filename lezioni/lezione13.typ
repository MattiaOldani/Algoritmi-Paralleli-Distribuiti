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


= Lezione 13

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

== Tecnica del ciclo euleriano

Vediamo un po' di basi di teoria dei grafi.

Un grafo diretto $D$ è una coppia $V,E$ dove $E subset.eq V^2$. Indichiamo un arco con $(v,e) in E$. Un cammino è una sequenza di archi $e_1, dots, e_k$ tale che per ogni coppia di lati consecutivi il nodo pozzo del primo coincide con il nodo sorgente del secondo. Un ciclo è un cammino tale che il nodo pozzo di $e_k$ è il nodo sorgente di $e_1$.

Un ciclo è euleriano quando ogni arco in $E$ compare una e una sola volta. Un cammino euleriano è la stessa cosa. Un grafo è euleriano se contiene un ciclo euleriano.

Il problema base è, dato un grafo $D$, è euleriano?

Diamo notazioni:
- $forall v in V$ definiamo $rho^-(v) = abs({(w,v) in E})$ numero di archi entranti in $v$ ed è detto grado di entrata di $v$;
- $forall v in V$ definiamo $rho^+(v) = abs({(v,w) in E})$ numero di archi uscenti da $v$ ed è detto grado di uscita di $v$

#theorem([di Eulero (1736)])[
  Un grado $D$ è euleriano se e solo se $ forall v in V quad rho^-(v) = rho^+(v) . $
]

Vediamo un problema simile: molto simile al ciclo hamiltoniano, ovvero un ciclo è hamiltoniano se e solo se è un ciclo dove ogni vertice in $V$ compare una e una sola volta. $D$ è hamiltoniano se e solo se contiene un ciclo hamiltoniano.

Per euleriano ho un algoritmo efficiente in $O(n^3)$ con $n = abs(V)$ mentre per hamiltoniano ho un problema NP completo.

Abbiamo una tecnica del ciclo euleriano: viene usata per costruire algoritmi paralleli efficienti che gestiscono strutture dinamiche come alberi binari.

Per trasformare un albero in una tabella con righe nodi e colonne figlio sx dx e il padre etichetto i nodi e poi popolo.

Molti problemi ben noti usano alberi binari:
- ricerca;
- costruzione di dizionari;
- query.

Fondamentale in questi problemi è la navigazione dell'albero (ricerca, manutenzione, modifica, cancellazione, inserimento).

Possiamo operare su queste strutture in parallelo con algoritmi efficienti.

Idea: usiamo delle liste che contengono dei puntatori ai nodi dell'albero, e le possiamo usare bene in parallelo (ad esempio Kogge-Stone per le somme prefisse).

Usiamo un vettore $S$ dei successori dell'albero, gli elementi sono i nodi dell'albero.
