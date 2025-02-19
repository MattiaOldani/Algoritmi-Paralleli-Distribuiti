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

= Routing

Vogliamo mandare un messaggio da $x$ a $y$ utilizzando il cammino minimo tra queste due entità. Il problema è che l'entità $x$ non conosce questo cammino minimo. Il problema del *routing* vuole risolvere le paturnie dell'entità $x$ così che possa fare sogni tranquilli.

Una soluzione è fare broadcast da $x$ del messaggio $E$, ma questo è totalmente inefficiente. Decidiamo quindi di scegliere uno tra tutti i possibili cammini tra $x$ e $y$ e, se questo è il migliore, siamo anche più contenti.

Visto che poi dobbiamo saperci spostare nella rete, dobbiamo salvare le informazioni sui costi della rete per ogni entità, così che possiamo calcolare i cammini minimi verso ogni entità.

Le informazioni le salviamo nella *full routing table*, una tabella con le varie destinazioni sulle righe e path minimo + costo sulle colonne (_grazie *Rossi* che me le hai insegnate queste cose_).

== Prima versione

Sotto restrizioni IR, vediamo il protocollo *gossiping*. L'idea è che ogni entità si costruisce una mappa del grafo $G$, una matrice che è praticamente la matrice di adiacenza, e all'occorrenza si calcola le righe della full routing table.

Per costruire questa tabella, detta $mapg(G)$, che contiene i costi dei vari archi, ogni entità diffonde le proprie informazioni sui vicini ad ogni altra entità vicina.

Vediamo cosa fa questo protocollo:
- costruisce l'albero $T$ per il grafo $G$;
- ogni entità diffonde le proprie informazioni a tutte le altre usando i link di $T$;
- ogni entità acquisisce dai vicini $id(x)$ e costi dei vari link.

Il numero di messaggi è:
- $n^2$ per la comunicazione;
- $m + n log(n)$ per la creazione dello spanning tree;
- $2m$ per acquisire informazioni dai vicini;
- $2m(n-1)$ per il broadcast delle informazioni su $T$.

In totale, il *numero di messaggi* è $approx 2 m n$, che vale $n^2$ quando $G$ è sparso. Il *tempo*, invece, è molto difficile da calcolare. Vediamo come questo protocollo richieda tanta memoria per poter essere eseguito.

== Seconda versione

Il protocollo *iterated-construction* costruisce la FRT di ogni entità a più riprese senza usare $mapg(G)$. Infatti, all'inizio ogni FRT contiene solo le informazioni dei vicini. Inoltre, nella FRT possiamo evitare di tenere tutto il cammino minimo, ma possiamo limitarci a salvare quale nodo è il prossimo nel cammino. Definiamo inoltre il *distance vector* $V$ come la FRT ristretta alle colonne con solo destinazione e costo, senza path.

Cosa fa questo protocollo:
- ogni entità diffonde la propria $V$ ai suoi vicini;
- sulla base delle informazioni ricevute, ogni entità stabilisce se sono stati trovati cammini minimi migliori di quelli della propria FRT e in tal caso la aggiorna.

Il *numero di iterazioni* di questo protocollo è $n-1$, e si dimostra per induzione.

Vediamo come fa $x$ ad individuare, ad ogni iterazione, il cammino minimo per un nodo $z$.

Sia $V_y^i [z]$ il costo del cammino da $y$ a $z$ alla $i$-esima iterazione. Alla $(i+1)$-esima iterazione questo costo arriva ai vicini di $y$, e sia $x$ uno di questi. Esso calcola il valore $ w[z] = min_(y in N(x)) {theta.alt(x,y) + V_y^i [z]}, $ dove $theta.alt(x,y)$ rappresenta il costo del link $(x,y)$. Se $w[z] < V_x^i [z]$ allora $x$ sceglie $w[z]$ come costo per il path per $z$, aggiornando la FRT e memorizzando anche il vicino $y$ che ci ha dato l'informazione.

Vediamo come utilizziamo molta meno memoria della $mapg(G)$, perché i DV sono lineari.

Il *numero di messaggi* è $2m n (n-1)$, ovvero eseguo $n-1$ iterazioni dove mando $n$ volte il distance vector su $2m$ link del grafo. Il *tempo ideale* lo indichiamo con $tau(n)$, ed è tale che $ tau(n) = cases(O(1) & "se G consente messaggi lunghi", O(n) quad & "altrimenti") . $

Se $tau(n) = O(1)$ il tempo diventa lineare in $n$ e il numero di messaggi è $O(m n)$. Se invece $tau(n) = O(n)$ il tempo diventa quadratico in $n$ e il numero di messaggi è $O(m n^2)$.
