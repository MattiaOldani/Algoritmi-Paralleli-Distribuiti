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


= Lezione 19

== Terza parte: ambiente di calcolo distribuito

Abbiamo un grafo orientato, dove i nodi sono entità e le frecce sono link/connessioni (non per forza full-duplex). Non abbiamo un clock globale. Ogni entità possiede:
- memoria locale
- capacità locale
- capacità di comunicazione
- clock locale proprio

Entità sono processori, processi, sensori, switch, eccetera

Nella memoria locale:
- registro di input, il registro è valore(x) = input dell'entità x
- registro di stato, il registro è stato(x) = stato dell'entità x, ovvero è il valore attuale dell'entità ed è cambiata localmente dalla stessa x

Per il clock locale, è possibile settare o resettare una sveglia

Proprietà delle entità:
- sono reattive: all'accadere di un evento compiono una azione
  - Eventi:
    - interni al sistema: ricezione di messaggi, sveglia
    - esterni al sistema: impulso spontaneo (START)
  - AZIONI:
    - sequenza finita di operazioni indivisibili (inizio l'azione e la porto a termine, non si blocca, un esempio è nil)
- seguono delle regole: una regola è un oggetto della forma stato x evento -> azione. Sia x una entità, definiamo B(x) l'insieme delle regole a cui è soggetta x. Questo insieme deve essere completo e non ambiguo, ovvero è praticamente il codice di x

Se $E$ insieme delle entità che cooperano tra loro, allora $ B(E) = union.big_(x in E) B(x) $ che è il comportamento del sistema, ed è importante che sia omogeneo, ovvero $ forall x,y in E quad B(x) = B(y) $ ovvero il codice deve essere uguale per tutte le entità

Il codice è detto algoritmo distribuito o protocollo per $E$, ma solo se $B(E)$ omogeneo

#lemma()[
  È sempre possibile ottenere $B(E)$ omogeneo
]

#proof()[
  Idea è utilizzare un registro locale aggiuntivo che differenzia quelle entità che alla stessa coppia stati x evento hanno azioni diverse. Questo è il registro ruolo(x) = ruolo di x. La regola viene modificata in $ "stato" times "evento" arrow.long "if" "ruolo"(x) = a "then" A_a "else" A_b $
]

Proprietà della rete:
- la comunicazione avviene usando una etichettatura sui link. Per l'entità x, l'etichettatura è denotata con $lambda x$ (nome di ogni link). x si trova in $G$, indichiamo con:
  - Nin(x) vicini di ingresso ad x
  - Nout(x) vicini di uscita di x
- assiomi della rete:
  - ritardo finito di comunicazione, in assenza di errori un messaggio è spedito prima o poi arriverà
  - orientamento locale, ogni entità riesce a distinguere tra i suoi vicini Nin e Nout grazie alla conoscenza di $lambda x$

Parametri della rete:
- numero di entità: $n$
- numero di link: $m$
- diametro della rete: $d$ (delta delle parallele)

Assioma abbiamo anche:
- restrizioni: dichiarate al momento della scrittura del codice, sono proprietà positive della rete su cui facciamo affidamento

Restrizioni sulla comunicazione:
- link bidirezionali: connessioni full-duplex, ovvero $ forall x quad "Nin"(x) = "Nout"(x) and lambda_x (x,y) = lambda_x (y,x) arrow.long.double N(x) $
- ordinamento dei messaggi: i messaggi sullo stesso link vengono prelevati con la politica FIFO

Restrizioni sull'affidabilità:
- rilevazione di errori, a livello di entità e di link, quindi l'abbiamo avuta
- affidabilità parziale (non ci saranno errori in futuro)
- affidabilità totale: non ci sono stati errori e non ce ne saranno in futuro

Restrizioni sulla topologia di rete:
- connettività del grafo, abbiamo fortemente connesso (per ogni coppia di entità abbiamo cammino bidirezionale che le collega) oppure connesso (grafo non diretto)

Restrizioni sul tempo:
- tempi di comunicazione unitari
- clock sincronizzati

Tali restrizioni a volte vengono considerate per il calcolo della prestazioni ideali del codice distribuito

Misure di complessità:
- tempo: intervallo tra la prima entità che si attiva e l'ultima che termina
- quantità di comunicazione: numero di messaggi spediti (se sono omogenei, ovvero stessa grandezza) e numero di bit spediti

Esecuzioni diverse dello stesso codice distribuito può portare a tempi diversi, quindi il tempo non va bene

Risolviamo quindi con il tempo ideale: tempo misurato considerando comunicazioni unitarie e clock sincroni

Il tempo causale (caso peggiore) è il tempo misurato considerando la catena più lunga di comunicazione richiesta dal codice. Questo difficile da calcolare.

Definizione di un problema: esso è una tripla Pinit, Pfinal e R, dove i primi due sono due predicati che descrivono le configurazioni del sistema all'inizio e alla fine, mentre R sono le restrizioni del sistema.

== Broadcasting

Pinit una entità tiene I: $ exists x in E bar.v "valore"(x) and forall y eq.not x quad "valore"(y) = emptyset.rev $

Pfinal: tutte le entità ce l'hanno, ovvero $ forall x in E quad "valore"(x) = I $

Le restrizioni sono:
- link bidirezionali BL
- affidabilità totale TR (total reliability)
- connettività CN
- queste tre sono R
- unico iniziatore UI (parte solo il primo che contiene x, detta I sta cosa)

Tutto detto RI

Vediamo un algoritmo distribuito / protollo

Diamo l'insieme di regole stato times evento --> azione:
- stato_t(x) stato di x al tempo t
- evento è impulso spontaneo, sveglia o messaggio
- azione è mini programma indivisibile

L'esecuzione di un protocollo genera una sequenza di configurazioni successive del sistema

Sia $sum(t)$ il contenuto dei registri delle entità al tempo $t$, sia futuro(t) eventi già generati al tempo $t$ ma che non sono ancora processati

Indichiamo con $C(t)$ la configurazione del sistema del tempo $t$, definita dalla coppia $sum(t), "futuro"(t)$

Definiamo $C(0) = (Sigma(0), "Futuro"(0))$ registri inizializzati + impulso spontaneo

L'esecuzione del protocollo è una sequenza di configurazioni successive tale che $C(0)$ a $C(f)$ con il protocollo

Quando una C soddisfa P lo scriviamo con $C in P$

Dobbiamo definire come un protocollo risolve un problema (definita dalla tripla)

Usiamo due stati S = {iniziatore, inattivo}. Abbiamo Sinit = stati delle entità in C(0) e Sterm = stati delle entità in C(f)

=== Prima versione

S = {iniziatore, inattivo}, Sinit = {iniziatore, inattivo} e Sfinal = {inattivo}

Iniziatore, se ricevo impulso spontaneo
- send(M) to N(x)
- become inattivo

Inattivo, se ricevo M
- processa M (preleva informazione e mettila in valore)
- send(M) to N(x)

Il messaggio è $M = (t, o, d, I)$ con $t$ tipologia del mex, o e d sono origine e destinatario, I informazione

Abbiamo un problema
