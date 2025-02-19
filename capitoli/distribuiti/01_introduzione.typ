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

= Introduzione

Le *architetture distribuite* sono rappresentate da *grafi orientati* dove:
- i *nodi* sono le entità del sistema, dotate di memoria locale, capacità di calcolo, capacità di comunicazione e un clock locale proprio;
- gli *archi* sono link/connessioni, non per forza full-duplex.

Vediamo come non abbiamo più un *clock globale*, ma ogni nodo pensa a se stesso.

Nella *memoria locale* di ogni processore abbiamo il *registro di input*, identificato da $valore(x)$, e il *registro di stato*, identificato da $rstato(x)$. Il primo registro identifica il valore di input dell'entità $x$, mentre il secondo registra il _valore attuale_ dell'entità $x$, e questo valore è cambiato localmente dalla stessa $x$.

Le entità hanno una serie di *proprietà*:
- *sono reattive*: all'accadere di un *evento* compiono una *azione*. Definiamo questi due concetti:
  - *eventi*: ciò che succede alle entità, essi possono essere:
    - *interni al sistema*: ricezione di messaggi;
    - *esterni al sistema*: impulso spontaneo (_START_);
  - *azioni*: sequenza finita di operazioni indivisibili che sono eseguite in risposta ad un evento. Con _"indivisibili"_ si intende un'azione che inizia e viene portata a termine. Un'azione particolare è *nil*, che indica l'azione vuota.
- *seguono delle regole*: una *regola* è un oggetto della forma $ stato times evento arrow.long azione . $ Sia $x$ una entità, definiamo con $B(x)$ l'insieme delle regole a cui è soggetta $x$. Questo insieme deve essere *completo* e *non ambiguo*. In poche parole, $B(x)$ rappresenta il codice di $x$.

Sia $E$ l'insieme delle entità che cooperano tra loro. Allora $ B(E) = union.big_(x in E) B(x) $ rappresenta il *comportamento del sistema*, ed è importante che sia *omogeneo*, ovvero $ forall x,y in E quad B(x) = B(y) . $ In poche parole, il codice/protocollo/algoritmo distribuito deve essere uguale per tutte le entità.

#lemma()[
  È sempre possibile ottenere un insieme $B(E)$ omogeneo.
]

#proof()[
  L'idea della dimostrazione è utilizzare un registro locale aggiuntivo che differenzia quelle entità che alla stessa coppia $(stato times evento)$ hanno $azione$ diversa. Questo è il registro $ruolo(x)$, che rappresenta appunto il ruolo di $x$. La regola viene modificata in $ stato times evento arrow.long { "if" ruolo(x) = a "then" azione_a "else" azione_b } . qedhere $
]

La rete ha una serie di *parametri*: essi sono il *numero di entità* $n$, il *numero di link* $m$ e il *diametro* della rete $d$, uguale a quello che avevamo nelle architetture precedenti.

La comunicazione avviene usando una *etichettatura* sui link. Per l'entità $x$, l'etichettatura è denotata con $lambda_x$ e poi l'arco che abbiamo davanti. Indichiamo inoltre con:
- $nin(x)$ insieme dei vicini di ingresso ad $x$;
- $nout(x)$ insieme dei vicini di uscita di $x$.

La rete ha una serie di *assiomi*:
- *ritardo finito di comunicazione*: in assenza di errori, un messaggio spedito prima o poi arriverà, non sappiamo quando ma arriverà;
- *orientamento locale*, ogni entità riesce a distinguere tra i suoi vicini gli insiemi $nin(x)$ e $nout(x)$ grazie alla conoscenza di $lambda_x$.

La rete, inoltre, può essere utilizzata con delle *restrizioni*: esse sono dichiarate al momento della scrittura del codice e sono delle *proprietà positive* della rete su cui facciamo affidamento. Vediamone alcune di quelle più usate:
- *restrizioni sulla comunicazione*:
  - *link bidirezionali*: le connessioni diventano full-duplex, ovvero $nin(x) = nout(x)$ e anche $lambda_x (x,y) = lambda_x (y,x)$. In questo caso indichiamo i vicini di $x$ semplicemente con $N(x)$;
  - *ordinamento dei messaggi*: i messaggi su un link vengono prelevati con la politica *FIFO*;
- *restrizioni sull'affidabilità*:
  - *rilevazione di errori*: entità e link possono rilevare gli errori;
  - *affidabilità parziale*: non ci saranno errori in futuro;
  - *affidabilità totale*: non ci sono stati errori prima e non ce ne saranno in futuro.
- *restrizioni sulla topologia di rete*:
  - *connettività del grafo*: imponiamo un grafo fortemente connesso (_se il grafo è orientato_) oppure un grafo connesso (_se il grafo è non orientato_);
- *restrizioni sul tempo*:
  - *tempi di comunicazione unitari*: il nome parla da sé;
  - *clock sincronizzati*: i clock delle entità scattano tutti allo stesso tempo.

Tali restrizioni a volte vengono considerate per il calcolo delle *prestazioni ideali* del codice distribuito. Le misure che possiamo fare prendono in considerazione:
- *tempo*: intervallo tra la prima entità che si attiva e l'ultima che termina;
- *quantità di comunicazione*: numero di messaggi spediti e/o numero di bit spediti.

Il tempo, così come lo usiamo di solito, non va più bene: esecuzioni diverse dello stesso codice distribuito possono portare a tempi diversi. Risolviamo questo problema con il *tempo ideale*: esso è il tempo misurato considerando comunicazioni unitarie e clock sincronizzati.

Il *tempo causale* (_tempo del caso peggiore_) è invece il tempo misurato considerando la catena più lunga di comunicazione richiesta dal codice. A differenza del tempo ideale, questa quantità è molto difficile da calcolare.

Definiamo quello che è un problema. Un *problema* è una tripla $ angle.l pinit, pfinal, R angle.r $ dove:
- $pinit$ rappresenta i predicati che descrivono il sistema all'avvio;
- $pfinal$ rappresenta i predicati che descrivono il sistema alla sua terminazione;
- $R$ rappresenta le restrizioni del sistema.

L'insieme $pinit$ contiene tutti i valori iniziali di stato che possiamo trovare nel sistema al suo avvio, ovvero abbiamo che $ forall x in E quad valore(x) in pinit . $

Una definizione simile si può dare anche per $pfinal$.

L'esecuzione di un protocollo genera una *sequenza di configurazioni* successive del sistema.

Sia $Sigma(t)$ il contenuto dei registri delle entità al tempo $t$, e sia $futuro(t)$ l'insieme degli eventi già generati al tempo $t$ ma che non sono ancora stati processati.

Indichiamo con $C(t)$ la *configurazione del sistema* del tempo $t$, definita dalla coppia $ (Sigma(t), futuro(t)) . $

Definiamo $ C(0) = (Sigma(0), futuro(0)) $ la *configurazione iniziale* che contiene i registri inizializzati e l'impulso spontaneo. Parallelamente, si può definire $C(f)$ come la *configurazione finale*.

Dentro $C(0)$ troveremo tutti gli stati presenti in $sinit$, insieme degli stati che troviamo all'avvio, mentre dentro $C(f)$ troveremo tutti gli stati presenti in $sterm$, insieme degli stati che troviamo alla fine.

Per finire, definiamo quali saranno le restrizioni che useremo praticamente sempre:
- link bidirezionali *BL*;
- affidabilità totale *TR* (_total reliability_);
- connettività *CN*;
- unico iniziatore *UI*.

Le prime tre restrizioni vengono indicate con *R*, l'ultima con *I*. La loro unione dà la restrizione *RI*.
