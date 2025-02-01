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

== Algoritmi paralleli e distribuiti

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
- *GPU*: usate in ambienti grafici, molto utili anche in ambito vettoriale;
- *processori multicore*;
- *circuiti integrati*: insieme di gate opportunamente connessi.

Un *algoritmo distribuito* è un algoritmo *asincrono* che risponde al motto _"ogni membro del pool è un mondo a parte"_, ovvero si hanno più entità che obbediscono al proprio clock personale. Abbiamo anche in questo caso dei collegamenti ma non dobbiamo supporre una memoria condivisa o qualche tipo di sincronizzazione, quindi dobbiamo utilizzare lo *scambio di messaggi*.

Qualche esempio di architettura distribuita:
- *reti di calcolatori*: internet;
- *reti mobili*: uso di diverse tipologie di connessione;
- *reti di sensori*: sistemi con limitate capacità computazionali che rispondono a messaggi _ack_, _recover_, _wake up_, eccetera.

Notiamo quindi che negli algoritmi paralleli ciò che conta è il *tempo*, mentre negli algoritmi distribuiti ciò che conta è il *coordinamento*.

== Definizione di tempo

Il *tempo* è una variabile fondamentale nell'analisi degli algoritmi. Definiamo prima la funzione $ T(x) = hash"operazioni elementari sull'istanza" x. $

Questo valore dipende fortemente dall'istanza $x$. Per risolvere questo problema, visto che noi vogliamo ragionare nel caso *worst case*, ovvero il caso che considera la situazione peggiore possibile, così da avere dei bound ragionevoli, definiamo ora il tempo come la funzione $ t(n) = max ({T(x) bar.v x in Sigma^n}), $ dove $n$ è la grandezza dell'input. Abbiamo quindi raggruppato le istanze di grandezza $n$ e abbiamo preso tra queste il tempo massimo.

Spesso saremo interessati al _tasso di crescita_ di $t(n)$, definito tramite *funzioni asintotiche*, e non ad una sua valutazione precisa.

Date $f,g: NN arrow.long NN$, le principali funzioni asintotiche sono:
- *O grande*: $f(n) = O(g(n)) arrow.long.double.l.r f(n) lt.eq c dot g(n) quad forall n gt.eq n_0$;
- *omega grande*: $f(n) = Omega(g(n)) arrow.long.double.l.r f(n) gt.eq c dot g(n) quad forall n gt.eq n_0$;
- *theta grande*: $f(n) = Theta(g(n)) arrow.long.double.l.r c_1 dot g(n) lt.eq f(n) lt.eq c_2 dot g(n) quad forall n gt.eq n_0$.

Il tempo $t(n)$ dipende da due fattori molto importanti: il *modello di calcolo* e il *criterio di costo*.

== Modelli di calcolo

Un *modello di calcolo* mette a disposizione le *operazioni elementari* che usiamo per formulare i nostri algoritmi. Modelli di calcolo sono le macchine RAM, le MdT, le macchine WHILE, eccetera.

#example([Funzione palindroma])[
  La funzione _palindroma_, che dice se una stringa $x$ di lunghezza $n$ data in input è palindroma, ha tempo:
  - $O(n)$ in una architettura con memoria ad accesso casuale;
  - $O(n^2)$ in una MdT.
]

== Criterio di costo

Le dimensioni dei dati in gioco contano: il *criterio di costo uniforme* afferma che le operazioni elementari richiedono una unità di tempo, mentre il *criterio di costo logaritmico* afferma che le operazioni elementari richiedono un costo che dipende dal numero di bit degli operandi, ovvero dalla sua dimensione.

== Classi di complessità

Un problema è *risolto efficientemente* in tempo se e solo se è risolto da una MdT in tempo polinomiale. Abbiamo tre principali classi di equivalenza per gli algoritmi sequenziali:
- $P$, classe dei problemi di decisione risolti in tempo polinomiale su una MdT;
- $FP$, classe delle funzioni risolte in tempo polinomiale su una MdT;
- $NP$, classe dei problemi di decisione risolti in tempo polinomiale su una MdTnd.

Il famosissimo problema $P = NP$ rimane ancora oggi aperto.

== Algoritmi paralleli

Il problema della *sintesi* si interroga su come costruire gli algoritmi paralleli, chiedendosi se sia possibile ispirarsi ad alcuni algoritmi sequenziali.

Il problema della *valutazione* si interroga su come misurare il tempo e lo spazio, unendo questi due in un un parametro di efficienza $E$. Spesso lo spazio conta il *numero di processori/entità* disponibili.

Il problema dell'*universalità* cerca di descrivere la classe dei problemi che ammettono problemi paralleli efficienti.

Definiamo infatti una nuova classe di complessità, ovvero la classe _NC_, che descrive la classe dei problemi generali che ammettono problemi paralleli efficienti. Un problema appartiene alla classe $NC$ se viene risolto in tempo _polilogaritmico_ e in spazio polinomiale

#theorem()[
  $ NC subset.eq FP . $
]

#proof()[
  Per ottenere un algoritmo sequenziale da uno parallelo faccio eseguire in sequenza ad una sola identità il lavoro delle entità che prima lavoravano in parallelo. Visto che lo spazio di un problema $NC$ è polinomiale, posso andare a _"comprimere"_ un numero polinomiale di operazioni in una sola entità. Infine, visto che il tempo di un problema $NC$ è polilogaritmico, il tempo totale è un tempo polinomiale.
]

Come per $P = NP$, qui il dilemma aperto è se vale $NC = FP$, ovvero se posso parallelizzare ogni algoritmo sequenziale efficiente. Per ora sappiamo che $NC subset.eq FP$, e che i problemi che appartengono a $FP$ ma non a $NC$ sono detti problemi $P$-completi.
