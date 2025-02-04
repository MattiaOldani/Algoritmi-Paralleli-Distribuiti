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

= Navigazione di strutture connesse

== Teoria dei grafi

Un *grafo diretto* $D$ è una coppia $(V,E)$ con:
- $V$ insieme di *vertici*;
- $E subset.eq V^2$ insieme di *archi*, indicati con la notazione $(s,d)$ oppure con un nome.

Un *cammino* è una sequenza di archi $[e_1, dots, e_k]$ tale che, per ogni coppia di lati consecutivi, il nodo pozzo (_destinazione_) del primo coincide con il nodo sorgente del secondo. Un *ciclo* è un cammino $[e_1, dots, e_k]$ nel quale il nodo pozzo di $e_k$ è il nodo sorgente di $e_1$.

#definition([Ciclo euleriano])[
  Un ciclo è *euleriano* quando ogni arco di $E$ compare una e una sola volta nel ciclo.
]

La definizione è praticamente identica se parliamo di cammino euleriano. Un *grafo euleriano* è un grafo che contiene un ciclo euleriano. Dato un grafo $D$, ci possiamo chiedere se esso sia euleriano.

Diamo ancora qualche notazione:
- *grado di entrata*: dato $v in V$ definiamo $rho^-(v) = abs({(w,v) in E})$ numero di archi entranti in $v$;
- *grado di uscita*: dato $v in V$ definiamo $rho^+(v) = abs({(v,w) in E})$ numero di archi uscenti da $v$.

#theorem([di Eulero _(1736)_])[
  Un grafo $D$ è euleriano se e solo se $ forall v in V quad rho^-(v) = rho^+(v) . $
]

Vediamo un problema simile a quello che abbiamo appena definito.

#definition([Ciclo hamiltoniano])[
  Un ciclo è *hamiltoniano* se e solo se ogni vertice di $V$ compare nel ciclo una e una sola volta.
]

Similmente a prima, $D$ è un *grafo hamiltoniano* se e solo se contiene un ciclo hamiltoniano.

La richiesta di controllo dell'esistenza di un ciclo euleriano ammette un algoritmo efficiente con tempo $T(n) = O(n^3)$, con $n = abs(V)$, mentre il controllo dell'esistenza di un ciclo hamiltoniano è, purtroppo per noi, un problema $NP$-completo.

== Alberi binari

Utilizzeremo i cicli euleriano per costruire algoritmi paralleli efficienti per *alberi binari*.

L'operazione fondamentale che useremo nei problemi è la *navigazione* dell'albero. Come possiamo fare una navigazione parallela efficiente?

Gli alberi spesso sono rappresentati come liste di puntatori, ma noi queste le sappiamo manipolare molto bene. Cercheremo quindi di trasformare queste strutture ad albero in liste a noi comode, così da comporre algoritmi paralleli efficienti che abbiamo già visto per risolvere i nostri nuovi problemi.

Il primo passo che facciamo è associare ad un albero binario un *ciclo euleriano*: sostituisco ogni arco dell'albero con un doppio arco orientato, così che possa effettivamente trovare un ciclo.

Ora trasformiamo questo ciclo in un cammino, espandendo ogni vertice $v$ in una terna $ (v,s) bar.v (v,c) bar.v (v,d) . $

Con questi nuovi vertici posso costruire un *cammino euleriano*:
- quando devo scendere di un livello collego il nodo corrente $v$ al nodo figlio $f$ nella sua componente sinistra $(f,s)$;
- quando devo salire di un livello collego il nodo corrente $v$ al nodo padre $p$ nella sua componente centrale o destra, in base alla posizione del nodo $v$ rispetto a $p$:
  - se $v$ è il figlio sinistro di $p$ mi collego al nodo $(p,c)$;
  - se $v$ è il figlio destro di $p$ mi collego al nodo $(p,d)$;
- quando non posso scendere di un livello scorro tutte le componenti del nodo corrente $v$.

Infine, devo costruire la lista $ S[(v,x)] quad bar.v quad v in V and x in {s, c, d} . $ Per costruire questa lista utilizziamo la *rappresentazione tabellare* dell'albero, ovvero una tabella che indica, per ogni vertice, chi sono il figlio sinistro, il figlio destro e il padre.

Se sono in un *nodo foglia* $v$ allora $ S[(v,s)] &= (v,c) \ S[(v,c)] &= (v,d) \ S[(v,d)] &= cases((pad(v), c) & "se" v = sin(pad(v)), (pad(v), d) quad & "se" v = des(pad(v))) . $

Se sono in un *nodo interno* $v$ allora $ S[(v,s)] &= (sin(v), s) \ S[(v,c)] &= (des(v), s) \ S[(v,d)] &= cases(("pad"(v), c) & "se" v = "sin"("pad"(v)), ("pad"(v), d) quad & "se" v = "des"("pad"(v))) . $

Diamo un algoritmo parallelo molto semplice per costruire questo vettore $S$:
- usiamo un processore per ogni vertice, ovvero per ogni riga della tabella;
- ogni processore per $v$ deve costruire le celle $S[v,{s,c,d}]$.

L'algoritmo non è EREW, perché facciamo letture concorrenti quando leggiamo la nostra riga e la riga dei padri. Con un piccolo accorgimento, questa concorrenza può essere eliminata. Non vedremo come, possiamo solo trustare il processo (*JOEL EMBIID*).

Algoritmo diventa EREW, usando $p(n) = n$ processori con tempo $T(n,p(n)) = O(1)$. Con il *principio di Wyllie* otteniamo $p(n) = n/log(n)$ processori e tempo $T = log(n)$.

== Attraversamento in pre-ordine

Definiamo, per ogni vertice $v in V$, la quantità $N(v)$, che indica l'*ordine di attraversamento* di $v$ durante una visita in *pre-ordine* dell'albero.

Definiamo un array $A$ tale che $ A[(v,x)] = cases(1 & "se" x = s, 0 quad & "altrimenti") . $ Sulla coppia $(A,S)$ andiamo ad applicare l'algoritmo di somme prefisse. Dentro la cella $A[(v,s)]$ avremo $N(v)$: questo è vero perché quando facciamo il cammino e visitiamo un nuovo nodo andiamo sempre nel suo nodo sinistro.

L'algoritmo è EREW con $p(n) = n/log(n)$ processori e tempo $T(n,p(n)) = log(n)$. L'efficienza vale $ E = frac(n, n/log(n) log(n)) arrow.long C eq.not 0 . $

== Profondità di un albero

Definiamo, per ogni vertice $v in V$, la quantità $P(v)$, che indica la *profondità* di $v$ nell'albero.

Definiamo un array $A$ tale che $ A[(v,x)] = cases(1 & "se" x = s, 0 & "se" x = c, -1 quad & "se" x = d) . $

Anche sulla coppia $(A,S)$ applichiamo l'algoritmo di somme prefisse. Otteniamo il valore $P(v)$:
- dentro la cella $A[(v,s)]$ se partiamo da $1$ a contare le altezze;
- dentro la cella $A[(v,d)]$ se partiamo da $0$ a contare le altezze.

L'efficienza vale $ E = frac(n, n/log(n) log(n)) arrow.long C eq.not 0 . $
