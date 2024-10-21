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


= Lezione 02

== Definizione di tempo

Il *tempo* è una variabile fondamentale nell'analisi degli algoritmi: lo definiamo come la funzione $t(n)$ tale per cui $ T(x) = "numero di operazioni elementari sull'istanza " x \ t(n) = max {T(x) bar.v x in Sigma^n}, $ dove $n$ è la grandezza dell'input.

Spesso saremo interessati al _tasso di crescita_ di $t(n)$, definito tramite funzioni asintotiche, e non ad una sua valutazione precisa.

Date $f,g: NN arrow.long NN$, le principali funzioni asintotiche sono:
- $f(n) = O(g(n)) arrow.long.double.l.r f(n) lt.eq c dot g(n) quad forall n gt.eq n_0$;
- $f(n) = Omega(g(n)) arrow.long.double.l.r f(n) gt.eq c dot g(n) quad forall n gt.eq n_0$;
- $f(n) = Theta(g(n)) arrow.long.double.l.r c_1 dot g(n) lt.eq f(n) lt.eq c_2 dot g(n) quad forall n gt.eq n_0$.

Il tempo $t(n)$ dipende da due fattori molto importanti: il *modello di calcolo* e il *criterio di costo*.

=== Modello di calcolo

Un modello di calcolo mette a disposizione le *operazioni elementari* che usiamo per formulare i nostri algoritmi.

Ad esempio, una funzione _palindroma_ in una architettura con memoria ad accesso casuale impiega $O(n)$ accessi, mentre una DTM impiega $Theta(n^2)$ accessi.

=== Criterio di costo

Le dimensioni dei dati in gioco contano: il *criterio di costo uniforme* afferma che le operazioni elementari richiedono una unità di tempo, mentre il *criterio di costo logaritmico* afferma che le operazioni elementari richiedono un costo che dipende dal numero di bit degli operandi, ovvero dalla sua dimensione.

== Classi di complessità

Un problema è *risolto efficientemente* in tempo se e solo se è risolto da una DTM in tempo polinomiale.

Abbiamo tre principali classi di equivalenza per gli algoritmi sequenziali:
- $P$, ovvero la classe dei problemi di decisione risolti efficientemente in tempo, o risolti in tempo polinomiale;
- $FP$, ovvero la classe dei problemi generali risolti efficientemente in tempo, o risolti in tempo polinomiale;
- $NP$, ovvero la classe dei problemi di decisione risolti in tempo polinomiale su una NDTM.

Il famosissimo problema _P = NP_ rimane ancora oggi aperto.

== Algoritmi paralleli

=== Sintesi

Il problema della *sintesi* si interroga su come costruire gli algoritmi paralleli, chiedendosi se sia possibile ispirarsi ad alcuni algoritmi sequenziali.

=== Valutazione

Il problema della *valutazione* si interroga su come misurare il tempo e lo spazio, unendo questi due in un un parametro di efficienza $E$. Spesso lo spazio conta il *numero di processori/entità* disponibili.

=== Universalità

Il problema dell'Universalità cerca di descrivere la classe dei problemi che ammettono problemi paralleli efficienti.

Definiamo infatti una nuova classe di complessità, ovvero la classe _NC_, che descrive la classe dei problemi generali che ammettono problemi paralleli efficienti.

Un problema appartiene alla classe _NC_ se viene risolto in tempo _polilogaritmico_ e in spazio polinomiale

#theorem()[
  $ NC subset.eq FP . $
]

#proof()[
  Per ottenere un algoritmo sequenziale da uno parallelo faccio eseguire in sequenza ad una sola identità il lavoro delle entità che prima lavoravano in parallelo. Visto che lo spazio di un problema $NC$ è polinomiale, posso andare a "comprimere" un numero polinomiale di operazioni in una sola entità. Infine, visto che il tempo di un problema $NC$ è polilogaritmico, il tempo totale è un tempo polinomiale.
]

Come per $P = NP$, qui il dilemma aperto è se vale $NC = FP$, ovvero se posso parallelizzare ogni algoritmo sequenziale efficiente. Per ora sappiamo che $NC subset.eq FP$, e che i problemi che appartengono a $FP$ ma non a $NC$ sono detti problemi $P$-completi.
