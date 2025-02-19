// Setup

#set heading(numbering: none)

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


// Capitolo

= Introduzione

Un *algoritmo* è una sequenza finita di istruzioni che non sono ambigue e che terminano, ovvero restituiscono un risultato. Gli *algoritmi sequenziali* avevano un solo esecutore, mentre gli algoritmi di questo corso utilizzano un *pool di esecutori*.

Le problematiche da risolvere negli algoritmi sequenziali si ripropongono anche qua, ovvero:
- *progettazione*: utilizzo di tecniche per la risoluzione, come _Divide et Impera_, _programmazione dinamica_ o _greedy_;
- *valutazione delle prestazioni*: complessità spaziale e temporale;
- *codifica*: implementare con opportuni linguaggi di programmazione i vari algoritmi presentati.

Un *algoritmo parallelo* è un algoritmo *sincrono* che risponde al motto _"una squadra in cui batte un solo cuore"_, ovvero si hanno più entità che obbediscono ad un clock centrale, che va a coordinare tutto il sistema.

Abbiamo la possibilità di condividere le risorse in due modi:
- memoria, formando le architetture
  - *a memoria condivisa*, ovvero celle di memoria fisicamente condivisa;
  - *a memoria distribuita*, ovvero ogni entità salva parte dei risultati parziali sul proprio nodo;
- uso di opportuni collegamenti.

Qualche esempio di architettura parallela:
- *supercomputer*: cluster di processori con altissime prestazioni;
- *GPU*: usate in ambienti grafici, molto utili anche in ambito vettoriale.

Un *algoritmo distribuito* è un algoritmo *asincrono* che risponde al motto _"ogni membro del pool è un mondo a parte"_, ovvero si hanno più entità che obbediscono al proprio clock personale. Abbiamo anche in questo caso dei collegamenti ma non dobbiamo supporre una memoria condivisa o qualche tipo di sincronizzazione, quindi dobbiamo utilizzare lo *scambio di messaggi*.

Qualche esempio di architettura distribuita:
- *reti di calcolatori*: rete internet;
- *reti di sensori*: sistemi con limitate capacità computazionali che rispondono a messaggi _ack_, _recover_, _wake up_, eccetera.

Il *tempo* è una variabile fondamentale nell'analisi degli algoritmi. Definiamo prima la funzione $ T(x) = hash"operazioni elementari sull'istanza" x. $

Questo valore dipende fortemente dall'istanza $x$. Per risolvere questo problema, visto che noi vogliamo ragionare nel caso *worst case*, ovvero il caso che considera la situazione peggiore possibile, così da avere dei bound ragionevoli, definiamo ora il tempo come la funzione $ t(n) = max ({T(x) bar.v x in Sigma^n}), $ dove $n$ è la grandezza dell'input. Abbiamo quindi raggruppato le istanze di grandezza $n$ e abbiamo preso tra queste il tempo massimo. Spesso saremo interessati al _tasso di crescita_ di $t(n)$, definito tramite *funzioni asintotiche*, e non ad una sua valutazione precisa.

Date due funzioni $f,g: NN arrow.long NN$, le principali funzioni asintotiche sono:
- *O grande*: $f(n) = O(g(n)) arrow.long.double.l.r f(n) lt.eq c dot g(n) quad forall n gt.eq n_0$;
- *omega grande*: $f(n) = Omega(g(n)) arrow.long.double.l.r f(n) gt.eq c dot g(n) quad forall n gt.eq n_0$;
- *theta grande*: $f(n) = Theta(g(n)) arrow.long.double.l.r c_1 dot g(n) lt.eq f(n) lt.eq c_2 dot g(n) quad forall n gt.eq n_0$.

Il tempo $t(n)$ dipende da due fattori molto importanti: il *modello di calcolo* e il *criterio di costo*.

Un *modello di calcolo* mette a disposizione le *operazioni elementari* che usiamo per formulare i nostri algoritmi. Modelli di calcolo sono le macchine RAM, le MdT, le macchine WHILE, eccetera.

#example([Funzione palindroma])[
  La funzione _palindroma_, che dice se una stringa $x$ di lunghezza $n$ data in input è palindroma, ha tempo:
  - $O(n^2)$ in una MdT;
  - $O(n)$ in una architettura con memoria ad accesso casuale.
]

Anche le dimensioni dei dati in gioco contano: il *criterio di costo uniforme* afferma che le operazioni elementari richiedono una unità di tempo, mentre il *criterio di costo logaritmico* afferma che le operazioni elementari richiedono un costo che dipende dal numero di bit degli operandi, ovvero dalla sua dimensione.

Con tutte queste nozioni possiamo creare una serie di *classi di complessità*. Un problema è *risolto efficientemente* in tempo se e solo se è risolto da una MdT in tempo polinomiale. Abbiamo tre principali classi di equivalenza per gli algoritmi sequenziali:
- $P$, classe dei problemi di decisione risolti in tempo polinomiale su una MdT;
- $FP$, classe delle funzioni risolte in tempo polinomiale su una MdT;
- $NP$, classe dei problemi di decisione risolti in tempo polinomiale su una MdTnd.

Per quanto riguarda gli algoritmi paralleli, definiamo una nuova classe di complessità, ovvero $NC$, classe delle funzioni che ammettono algoritmi paralleli efficienti. Un problema appartiene alla classe $NC$ se viene risolto in tempo _polilogaritmico_ e in spazio _polinomiale_.

#theorem()[
  Vale $ NC subset.eq FP . $
]

#proof()[
  Per ottenere un algoritmo sequenziale da uno parallelo, faccio eseguire in sequenza ad una sola identità il lavoro delle entità che prima lavoravano in parallelo.

  Visto che lo spazio di un problema $NC$ è polinomiale, ovvero abbiamo un numero polinomiale di processori, abbiamo un _"programma unico"_ con una grandezza polinomiale.

  Ogni parte di questo _"super programma"_ ha tempo polinomiale, il tempo totale è un polinomio per un polilogaritmo, quindi il tempo è polinomiale.
]

Come per il famosissimo problema $P = NP$, qui il dilemma aperto è se vale $NC = FP$, ovvero se posso parallelizzare ogni algoritmo sequenziale efficiente. Per ora sappiamo che $NC subset.eq FP$, e che i problemi che appartengono a $FP$ ma non a $NC$ sono detti $P$-completi.
