// Setup

#import "template.typ": project

#show: project.with(
  title: "Algoritmi paralleli e distribuiti"
)

#import "@preview/algo:0.3.3": algo, i, d

#import "@preview/lemmify:0.1.5": *

#let (
  theorem, lemma, corollary,
  remark, proposition, example,
  proof, rules: thm-rules
) = default-theorems("thm-group", lang: "it")

#show: thm-rules

#show thm-selector("thm-group", subgroup: "proof"): it => block(
    it,
    stroke: green + 1pt,
    inset: 1em,
    breakable: true
)

#pagebreak()

// Appunti

= Introduzione

== Definizione

Un *algoritmo* è una sequenza finita di istruzioni che non sono ambigue e che terminano, ovvero restituiscono un risultato

Gi *algoritmi sequenziali* avevano un solo esecutore, mentre gli algoritmi di questo corso utilizzano un *pool di esecutori*

Le problematiche da risolvere negli algoritmi sequenziali si ripropongono anche qua, ovvero:
- *progettazione*: utilizzo di tecniche per la risoluzione, come _Divide et Impera_, _programmazione dinamica_ o _greedy_
- *valutazione delle prestazioni*: complessità spaziale e temporale
- *codifica*: implementare con opportuni linguaggi di programmazione i vari algoritmi presentati

I programmi diventano quindi una _sequenza di righe_, ognuna delle quali contiene _una o più_ istruzioni

== Algoritmi paralleli

Un *algoritmo parallelo* è un algoritmo *sincrono* che risponde al motto _"una squadra in cui batte un solo cuore"_, ovvero si hanno più entità che obbediscono ad un clock centrale, che va a coordinare tutto il sistema

Abbiamo la possibilità di condividere le risorse in due modi:
- memoria, formando le architetture
  - *a memoria condivisa*, ovvero celle di memoria fisicamente condivisa
  - *a memoria distribuita*, ovvero ogni entità salva parte dei risultati parziali sul proprio nodo
- uso di opportuni collegamenti

Qualche esempio di architettura parallela:
- *supercomputer*: cluster di processori con altissime prestazioni
- *GPU*: usate in ambienti grafici, molto utili anche in ambito vettoriale
- *processori multicore*
- *circuiti integrati*: insieme di gate opportunamente connessi

== Algoritmi distribuiti

Un *algoritmo distribuito* è un algoritmo *asincrono* che risponde al motto _"ogni membro del pool è un mondo a parte"_, ovvero si hanno più entità che obbediscono al proprio clock personale

Abbiamo anche in questo caso dei collegamenti ma non dobbiamo supporre una memoria condivisa o qualche tipo di sincronizzazione, quindi dobbiamo utilizzare lo *scambio di messaggi*

Qualche esempio di architettura distribuita:
- *reti di calcolatori*: internet
- *reti mobili*: uso di diverse tipologie di connessione
- *reti di sensori*: sistemi con limitate capacità computazionali che rispondono a messaggi _ack_, _recover_, _wake up_, eccetera

== Differenze

Vediamo un problema semplicissimo: _sommare quattro numeri A,B,C,D_

#v(12pt)

#figure(
    image("assets/somma_numeri.svg", width: 50%)
)

#v(12pt)

Usiamo la primitiva `send(sorgente,destinazione)` per l'invio di messaggi

Un approccio parallelo a questo problema è il seguente

#algo(
  title: "Somma di quattro numeri",
  parameters: ("A","B","C","D")
)[
  send(1,2), send(3,4)\
  A+B, C+D\
  send(2,4)\
  A+B+C+D
]

Un approccio distribuito invece non può seguire questo pseudocodice, perché le due send iniziali potrebbero avvenire in tempi diversi

Notiamo come negli algoritmi paralleli ciò che conta è il *tempo*, mentre negli algoritmi distribuiti ciò che conta è il *coordinamento*

== Definizione di tempo

Il *tempo* è una variabile fondamentale nell'analisi degli algoritmi: lo definiamo come la funzione $t(n)$ tale per cui $ T(x) = "numero di operazioni elementari sull'istanza " x \ t(n) = max {T(x) bar.v x in Sigma^n}, $ dove $n$ è la grandezza dell'input

Spesso saremo interessati al _tasso di crescita_ di $t(n)$, definito tramite funzioni asintotiche, e non ad una sua valutazione precisa

Date $f,g: NN arrow.long NN$, le principali funzioni asintotiche sono
- $f(n) = O(g(n)) arrow.long.double.l.r f(n) lt.eq c dot g(n) space.quad forall n gt.eq n_0$
- $f(n) = Omega(g(n)) arrow.long.double.l.r f(n) gt.eq c dot g(n) space.quad forall n gt.eq n_0$
- $f(n) = Theta(g(n)) arrow.long.double.l.r c_1 dot g(n) lt.eq f(n) lt.eq c_2 dot g(n) space.quad forall n gt.eq n_0$

Il tempo $t(n)$ dipende da due fattori molto importanti: il *modello di calcolo* e il *criterio di costo*

=== Modello di calcolo

Un modello di calcolo mette a disposizione le *operazioni elementari* che usiamo per formulare i nostri algoritmi

Ad esempio, una funzione _palindroma_ in una architettura con memoria ad accesso casuale impiega $O(n)$ accessi, mentre una DTM impiega $Theta(n^2)$ accessi

=== Criterio di costo

Le dimensioni dei dati in gioco contano: il *criterio di costo uniforme* afferma che le operazioni elementari richiedono una unità di tempo, mentre il *criterio di costo logaritmico* afferma che le operazioni elementari richiedono un costo che dipende dal numero di bit degli operandi, ovvero dalla sua dimensione

== Classi di complessità

Un problema è *risolto efficientemente* in tempo se e solo se è risolto da una DTM in tempo polinomiale

Abbiamo tre principali classi di equivalenza per gli algoritmi sequenziali:
- _P_, ovvero la classe dei problemi di decisione risolti efficientemente in tempo, o risolti in tempo polinomiale
- _FP_, ovvero la classe dei problemi generali risolti efficientemente in tempo, o risolti in tempo polinomiale
- _NP_, ovvero la classe dei problemi di decisione risolti in tempo polinomiale su una NDTM

Il famosissimo problema _P = NP_ rimane ancora oggi aperto

#pagebreak()

= Algoritmi paralleli

== Sintesi

Il problema della *sintesi* si interroga su come costruire gli algoritmi paralleli, chiedendosi se sia possibile ispirarsi ad alcuni algoritmi sequenziali

== Valutazione

Il problema della *valutazione* si interroga su come misurare il tempo e lo spazio, unendo questi due in un un parametro di efficienza $E$

Spesso lo spazio conta il *numero di processori/entità* disponibili

== Universalità

Il problema dell'Universalità cerca di descrivere la classe dei problemi che ammettono problemi paralleli efficienti

Definiamo infatti una nuova classe di complessità, ovvero la classe _NC_, che descrive la classe dei problemi generali che ammettono problemi paralleli efficienti

Un problema appartiene alla classe _NC_ se viene risolto in tempo _polilogaritmico_ e in spazio polinomiale

#theorem()[
  $italic("NC") subset.eq italic("FP")$
]<thm>

#proof[
  Per ottenere un algoritmo sequenziale da uno parallelo faccio eseguire in sequenza ad una sola identità il lavoro delle entità che prima lavoravano in parallelo \ Visto che lo spazio di un problema _NC_ è polinomiale, posso andare a "comprimere" un numero polinomiale di operazioni in una sola entità \ Infine, visto che il tempo di un problema _NC_ è polilogaritmico, il tempo totale è un tempo polinomiale
]<proof>

Come per _P = NP_, qui il dilemma aperto è se vale _NC = FP_, ovvero se posso parallelizzare ogni algoritmo sequenziale efficiente

Per ora sappiamo che $italic("NC") subset.eq italic("FP")$, e che i problemi che appartengono a _FP_ ma non a _NC_ sono detti problemi _P_-completi
