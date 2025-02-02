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

= Navigazione

== Cicli euleriani

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

Associamo ad un albero binario un ciclo euleriano: sostituisco ogni ramo dell'albero con un doppio arco orientato. In questo modo navigo l'albero seguendo il ciclo euleriano.

Così abbiamo un ciclo, noi vogliamo un cammino. Ogni vertice $v$ viene espanso in tre vertici $(v,s), (v,c), (v,d)$ sinistra centro destra. Con questi nuovi vertici creo un cammino: quando devo scendere di altezza collego al nodo $s$, se non posso scendere scorro tutti, se devo salire mi collego a $c$ o a $d$ (in ordine).

Terzo e ultimo passo è costruire una lista dal cammino euleriano. Quindi avrò $S((v,x))$ con $1 lt.eq v lt.eq n$ e $x in {s,c,d}$. Costruiamo questa lista a partire dalla tabella con delle regole per nodi foglia o nodi interni.

Se sono in un nodo foglia $v$ allora $ S[(v,s)] = (v,c) \ S[(v,c)] = (v,d) \ S[(v,d)] = cases(("pad"(v), c) "se" v = "sin"("pad"(v)), ("pad"(v), d) "se" v = "des"("pad"(v))) . $

Se sono in un nodo interno $v$ allora $ S[(v,s)] = ("sin"(v), s) \ S[(v,c)] = ("des"(v), s) \ S[(v,d)] = cases(("pad"(v), c) "se" v = "sin"("pad"(v)), ("pad"(v), d) "se" v = "des"("pad"(v))) . $

Ultima regola è uguale per tutti.

Diamo un algoritmo parallelo per costruire $S$:
- un processore per ogni vertice, ovvero per ogni riga della tabella;
- il processore deve costruire $S[v,...]$
- le letture sono concorrenti, ho accesso a tutta la riga di $v$ ma anche alle righe dei padri. Possiamo eliminare la concorrenza, ci fidiamo. Ad esempio, si fa con i nodi pari/dispari con piccoli accorgimenti per leggere solo dalla propria parte.

Algoritmo EREW con $p(n) = n$ e $T(n,p(n)) = O(1)$. Cambiamo con Wyllie e otteniamo $p(n) = n/log(n)$ e $T = log(n)$.

L'array $S$ è utile per risolvere i problemi:
- attraversamento in pre-ordine;
- calcolare la profondità dei nodi.

Abbiamo bisogno di due definizioni:
- $forall v in V$ allora $N(v)$ indica l'ordine di attraversamento di $v$ in pre-ordine;
- $forall v in V$ allora $P(v)$ indica la profondità di $v$ nell'albero.

La radice ha $N(v) =  1$ mentre la foglia più a destra ha $N(v) = n$. La radice ha $P(v) = 1 slash 0$, il figlio della radice uno in più.

== Attraversamento in pre-ordine

Dai una definizione di pre-ordine (prima radice, poi sx, poi dx).

Definiamo un array $A$ tale che $ A[(v,x)] = cases(1 "se" x = s, 0 "altrimenti") quad forall v in V . $ Ora, su $(A,S)$ andiamo ad applicare somme prefisse. Dentro la cella $A[(v,s)]$ avremo $N(v)$ perché quando facciamo il cammino e visitiamo un nuovo nodo andiamo sempre nel suo nodo sinistro.

L'algoritmo calcola $A$ e $S$, calcola somme prefisse su $A$ e $S$. L'output è nel nodo $A[(v,s)]$.

L'algoritmo è EREW con $p(n) = n/log(n)$ e $T(n,p(n)) = log(n)$ per entrambi i passi, quindi ottengo $ E = frac(n, n/log(n) l(n)) arrow C eq.not 0 $ ottimale si gode.

Per la profondità dei nodi ci serve un array tale che $ A[(v,x)] = cases(1 x = s, 0 x = c, -1 x = d) . $

Anche su questo vettore applichiamo le somme prefisse. Troviamo $P(v)$ nella cella $A[(v,d)]$.

L'algoritmo parallelo per la profondità calcola $A$ e $S$, calcolo le somme prefisse su $(A,S)$, l'output è in $A[(v,s)]$ se partiamo da 1, altrimenti in $A[(v,d)]$ se partiamo da 0.

Abbiamo efficienza $ E = frac(n, n/log(n) log(n)) arrow.long C eq.not 0 $ quindi anche lui ottimale efficiente.
