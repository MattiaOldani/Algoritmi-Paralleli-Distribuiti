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

= Traversal

Il problema *traversal* richiede di visitare *SEQUENZIALMENTE* ogni entità del nostro sistema. In poche parole, ad ogni unità di tempo devo visitare al massimo una entità nuova.

== Prima versione

Per risolvere questo problema useremo una *visita in profondità* con il protocollo *depth-first traversal*. Inoltre, useremo un messaggio particolare, un *token* $T$, che può viaggiare nelle rete al massimo una volta in ogni istante di tempo.

Vediamo i passi che segue questo protocollo:
- un nodo che riceve $T$ per la prima volta ricorda il sender e invia il token ad uno dei suoi vicini, aspettando un messaggio di *return/back-edge*. Quando riceve questo messaggio, effettua queste operazioni per ogni entità vicina. Quando la lista finisce, invia un return al sender;
- un nodo che ha già ricevuto $T$ spedisce un back-edge al sender.

Notiamo subito che abbiamo tre tipi di messaggi: il *token* $T$, il *return* (_ho finito la visita dei vicini_) e il *back-edge* (_ho già ricevuto il token, quindi sono già stato visitato_).

Utilizziamo per il DF-traversal i seguenti *stati*:
- $S = {"initiator", "idle", "visited", "done"}$;
- $sinit = {"initiator", "idle"}$;
- $sterm = {"done"}$.

Come restrizioni usiamo ancora *RI*.

#align(center)[
  #pseudocode-list(title: [*Initiator*])[
    + Se riceve un impulso spontaneo
      - initiator = true
      - unvisited = $N(x)$
      - $"visit"()$
  ]
]

#align(center)[
  #pseudocode-list(title: [*Idle*])[
    + Se riceve $T$
      - entry = sender
      - unvisited = $N(x) - sender$
      - initiator = false
      - $"visit"()$
  ]
]

#align(center)[
  #pseudocode-list(title: [*Visited*])[
    + Se riceve $R$
      - $"visit"()$
    + Se riceve $B$
      - $"visit"()$
    + Se riceve $T$
      - unvisited = unvisited - sender
      - send $B$ to sender
  ]
]

#align(center)[
  #pseudocode-list(title: [*Procedura visit*])[
    + if unvisited $eq.not emptyset.rev$
      + next = unvisited
      + $send(T)$ to next
      + become visited
    + else
      + if initiator == false
        + $send(R)$ to entry
      + become done
  ]
]

Per tutto il resto c'è *mastercard*.

Per calcolare la *complessità*, notiamo che se $x$ e $y$ sono due entità, sul loro canale passa sempre il token $T$ e il return $R$ o il back-edge $B$. Il traversal è *sequenziale*, quindi passo per tutte le entità una per volta con il token, ma allora *tempo* e *numero di messaggi* sono $2m$, perché mando due messaggi per ogni arco. Vediamo i *lower bound* di questo problema.

Il numero di messaggi è $M["traversal"] gt.eq m$ per il teorema che abbiamo visto nel problema Broadcast. Il tempo invece è $T["traversal"] gt.eq n-1$ perché ogni nodo viene visitato in sequenza. Notiamo che in un grafo, il numero di archi è tale che $ n - 1 lt.eq m lt.eq frac(n (n-1), 2), $ quindi il tempo che abbiamo con questo algoritmo è $O(n^2)$.

Con questi bound, il nostro algoritmo è ottimale per il numero di messaggi, ma non il tempo.

== Seconda versione

Cerchiamo di migliorare il nostro protocollo. Osserviamo che ad ogni istante di tempo viaggia un solo messaggio: cerchiamo di aggiungere *concorrenza* con una quantità di messaggi dell'ordine di $O(m)$ per rendere più veloce il protocollo.

Notiamo che un nodo non visitato che riceve il token $T$ potrebbe dire ai suoi vicini che lo ha ricevuto e che non dovrebbero poi mandarglielo in futuro. Questa idea cerca di evitare l'invio di un token $T$ su un link che sarebbe back-edge. Questa situazione effettivamente non si presenta, perché il tutto dipende dai clock delle singole entità, ma migliora considerevolmente le prestazioni.

Il nuovo numero di messaggi è $2n - 2$ per i token $T$ e le return $R$, sommati a $2m - (n-1)$ per i messaggi ai visited, sommati a $2(m - (n-1))$ per gli errori di invio de token sui back-edge. In totale abbiamo un numero di messaggi che è $O(m)$.

Calcolando il tempo ideale di questa soluzione, ovvero il tempo che non contiene ritardi, errori, e fa viaggiare token $T$ e avvisi di visited assieme, esso diventa $T(n) = n - 1$ che è il nostro lower bound.

Questo nuovo protocollo, che chiamiamo *DF\*-traversal*, è ottimo per messaggi e tempo.

Vediamo gli *stati* che utilizza:
- $S = {"initiator", "idle", "available", "visited", "done"}$;
- $sinit = {"initiator", "idle"}$;
- $sterm = {"done"}$.

Vediamo infine come funziona effettivamente il protocollo.

#align(center)[
  #pseudocode-list(title: [*Initiator*])[
    + Se riceve impulso spontaneo
      - initiator = true
      - unvisited = $N(x)$
      - next = unvisited
      - $send(T)$ to next
      - $send(V)$ to $N(x) - next$
      - become visited
  ]
]

#align(center)[
  #pseudocode-list(title: [*Idle*])[
    + Se riceve $T$
      - unvisited = $N(x)$
      - $"first-visit"()$
    + Se riceve $V$
      - unvisited = $N(x) - sender$
      - become available
  ]
]

#align(center)[
  #pseudocode-list(title: [*Available*])[
    + Se riceve $T$
      - $"first-visit"()$
    + Se riceve $V$
      - unvisited = unvisited - sender
  ]
]

#align(center)[
  #pseudocode-list(title: [*Visited*])[
    + Se riceve $V$
      - unvisited = unvisited - sender
      - if (next == sender) then $"visit"()$
    + Se riceve $T$
      - unvisited = unvisited - sender
      - if (next == sender) then $"visit"()$
    + Se riceve $R$
      - $"visit"()$
  ]
]

#align(center)[
  #pseudocode-list(title: [*Procedura first-visit*])[
    - la usiamo la prima volta che si riceve il token $T$
    + initiator = false
    + entry = sender
    + unvisited = unvisited - sender
    + if unvisited $eq.not emptyset.rev$
      + next = unvisited
      + $send(T)$ to next
      + $send(V)$ to $N(x) - {sender,next}$
      + become visited
    + else
      + $send(R)$ to sender
      + $send(V)$ to $N(x) - sender$
      + become done
  ]
]

#align(center)[
  #pseudocode-list(title: [*Procedura visit*])[
    - la usiamo quando abbiamo già mandato il visited $V$
    + if unvisited $eq.not emptyset.rev$
      + next = unvisited
      + $send(T)$ to next
    + else
      + if initiator == false
        + $send(R)$ to entry
      + become done
  ]
]
