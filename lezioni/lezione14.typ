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


= Lezione 14

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

== Architettura distribuita

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
