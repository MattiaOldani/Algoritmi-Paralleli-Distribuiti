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

= Routing

Scopo: x vuole spedire messaggio a y, vuole cammino in G da x a y

Problema shortest path: scopo determinare cammino migliore (di costo minimo) tra x e y in G

Applicazioni: comunicazione, cruciale in una computazione di un sistema distribuito

Per risolvere il primo basta fare broadcast da x del messaggio a tutte le y in E, ma totalmente inefficiente

Scegliamo quindi un cammino tra i tanti possibili tra x e y. Ovviamente se è il migliore possibile lo preferiamo

Secondo problema: richiede l'uso della memoria per registrare informazioni sui costi di G per ogni entità al fine di calcolare i cammini minimi verso ogni altra entità

Shortest path

Mettiamo restrizioni IR. Le strategie differiscono dal tipo di info che le entità tengono in memoria.

Full routing table: ogni strategia alla fine ha bisogno di questa tabella per risolvere il problema

La tabella ha come righe le destination, mentre sulle colonne il path minimo e il costo (momento reti)

Protocollo gossiping (tanta memoria)

Idea: ogni entità costruisce una mappa del sistema G, una matrice che è la matrice di adiacenza di G e all'occorrenza di calcola le righe della full routing table

Questa la chiamo MAP(G). Nella cella i,j ho peso arco i,j

Per costruire la MAP(G) in un distribuito ogni entità x diffonde le proprio informazioni sui vicini ad ogni altra y in E

Map-Gossip
- costruzione di un albero T per G
- ogni entità acquisice dai vicini id e i costi del link
- ogni entità diffonde le sue informazioni a tutte le altre usando i link di T

Complessità:
- comunicazione di $n^2$ messaggi
  - spanning tree T è $O(m + n log(n))$ il migliore (non l'abbiamo visto)
  - prendo info dai vicini $2m$
  - broadcast delle info su T $2m(n-1)$
- quindi M[Map-Gossip] circa 2 m n ovvero $O(n^2)$ se sparso, tempo difficile da calcolare

Richiede tanta memoria

Protocollo Iterated-Construction

Strategia: ogni x costruisce la FRT a più riprese senza usare MAP

Inizialmente la FRT contiene info solo sui vicini, mentre i non vicini hanno infinito

Notiamo che la FRT non deve contenere per forza l'intero shortest path per arrivare a z, basta sapere il vicino coinvolto nello shortest per z

Ovvero $ forall z in E bar.v z eq.not x quad cases("costo dello SP per z", "primo link dello SP che si traduce in un nodo") $

Definiamo il distance vector, ovvero la FRT ristretta alle colonne, con solo destination e cost. Indichiamo sta roba con V

Con V[z] indichiamo il cammino minimo da x a z

Iterazione:
- ogni entità diffonde la propria V ai suoi vicini
- sulla base delle info che gli arrivano dai vicini stabilisce se sono stati trovati cammini minimi migliori di quelli della propria FRT e in tal caso la aggiorna

Il numero di iterazioni è $n-1$m si dimostra per induzione

Come fa x ad individuare ad ogni iterazione il cammino minimo per arrivare a z?

Sia $V_y^i[z]$ il costo del cammino da y a z alla i-esima iterazione. Alla i+1-esima questo costo arriva ai vicini di y.

Sia x uno dei vicini, x si calcola, alla i-esima, $ w[z] = min_(y in N(x)) {theta.alt(x,y) + V_y^i[z]} $ dove theta è il costo del link x,y

Se w[z] < V_x^i[z] allora x sceglie w[z] come costo per lo sp per z, aggiornato la FRT e memorizza anche il vicino che ha dato questo costo minimo

Vantaggi: la memoria, meno spazio della map, i DV sono lineari, le MAP erano quadratiche

Complessità:
- M[/IR] = 2m n (n-1) ovvero n-1 iterazioni, mando n volte V e 2m sono i link del grafo
- T[/IR] = (n-1) tau(n) tempo ideale per trasmettere V, che è O(1) quando G consente messaggi lunghi, altrimenti O(n)

Se tau O(1) diventa tempo lineare in n e M = O(mn)

Nell'altro caso abbiamo O(mn^2) per i messaggi e tempo quadratico
