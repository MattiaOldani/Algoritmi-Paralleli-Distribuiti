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

= Traversal

Ogni entità della rete deve essere visitata MA sequenzialmente, cioè una dopo l'altra. Applicazioni è la gestione delle risorse condivise. Versione ristretta del wake up.

Si parte da una visitata, le altre sono dormienti/unvisited, finale ho tutte visited ma una alla volta, in sequenza, ad ogni unità di tempo se ne aggiunge una nuova alla volta

Protocollo depth-first traversal, ovvero una visita in profondità, "si scende sempre verso il vicino non ancora visitato"

Usiamo un messaggio particolare, un token T. In ogni istante di tempo deve viaggiare al più un token. Quando un nodo lo riceve diventa visitato.

Passi:
- un nodo che riceve $T$ per la prima volta:
  - ricorda il sender
  - fa una lista dei vicini non visitati
  - invia $T$ ad uno di essi
  - aspetta un messaggio da quest'ultima di return/back-edge (svegliata da T / già ricevuto il token)
- il vicino che ricevete $T$:
  - se è il primo $T$ ripete il punto 1
  - altrimenti (già visitato) spedisce back-edge
- solo dopo aver finito la lista dei vicini non visitati, un nodo deve inviare la return al sender

Abbiamo tre tipi di messaggi:
- T token (ordine)
- B back-edge (già visitato)
- R return (finito con i vicini)

Vediamo DF-traversal:
- S = {initiator, idle, visited, done}
- Sinit = {initiator, idle}
- Sterm = {done}

Restrizioni sono RI

Initiator
- se impulso spontaneo
  - initiator = true
  - unvisited = N(x)
  - visit

Idle
- se receiving(T)
  - entry = sender
  - unvisited = N(x) - sender
  - initiator = false
  - visit

Procedura VISIT
- if unvisited non vuoto then
  - next = unvisited
  - send(T) to next
  - become visited
- else
  - if (initiator == false) then
    - send(return) to entry
  - become done

Visited
- se receiving(return)
  - visit
- se receiving(back-edge)
  - visit
- se receiving(T)
  - unvisited = unvisited - sender
  - send(back-edge) to sender

Per tutto il resto c'è mastercard

Complessità: osserviamo che se $x,y$ sono identità, sul loro canale passa il token + return o back-edge

Traversal è sequenziale, perché le attivo una alla volta, ma allora T[DF-traversal] e M[DF-traversal] sono 2m (M perché mando due messaggi per m archi), mentre il tempo idem perché sono sequenziale

Vediamo i lower bound di traversal:
- M[traversal] gt.eq m (vale per broadcast)
- T[traversal] gt.eq n-1 (ogni nodo viene visitato in sequenza)

Nel caso di un grafo connesso si passa a $ n - 1 lt.eq m lt.eq frac(n(n-1), 2) = O(n^2) $ quindi DF-traversal ottimo per messaggi ma nel caso peggiore non ottimo per il tempo, passiamo da n teorico a n^2 peggiore

Osservazione: il problema per il costo del tempo è che ad ogni istante viaggia un solo messaggio --> mettiamo concorrenza, aggiungendo una quantità opportuna di messaggi $O(m)$ che possano rendere più veloce il protocollo

Possiamo evitare di inviare T su un link back-edge?

Idea: un nodo non visitato che riceve $T$ comunica l'evento ai vicini mandando un messaggio visited, così i vicini tolgono quel nodo dagli unvisited

Abbiamo evitato i link back-edge? NO, ma migliorato lo stesso

La nuova complessità è:
- messaggi
  - 2n-2 per T + return
  - 2m - (n-1) per visited
  - 2(m - (n-1)) per errori sull'invio dei T su back-edge

In totale è O(m)

Tempo ideale non ho ritardi e gli errori non capitano. Inoltre, visited viaggia assieme a T, quindi il tempo diventa 2(n-1) (TR) = O(n) che è finalmente il lower bound

DF\* è protocollo con ste modifiche, ed è ottimo per messaggi e tempo

S = {initiator, idle, available, visited, done}, Sinit = {initiator, idle}, Sterm = {done}

Initiator
- spontaneo
  - initiator = true
  - unvisited = N(x)
  - next = unvisited
  - send T to next
  - send visited to N(x) - next
  - become visited

Idle
- riceve T
  - unvisited = N(x)
  - first-visit
- riceve visited
  - unvisited = N(x) - sender
  - become available

Available
- ricevet T
  - first-visit
- riceve visited
  - unvisited = unvisited - sender

Visited
- riceve visited
  - unvisited = unvisited - sender
  - if (next = sender) then visit
- riceve T
  - unvisited = unvisited - sender
  - if (next = sender) then visit
- riceve return
  - visit

Procedura first-visit (prima volta che si riceve il token per mandare tutto asssieme)
- initiator = false
- entry = sender
- unvisited = unvisited - sender
- if non vuoto then
  - next = unvisited
  - send(T) to next
  - send(visited) to N(x) - {entry,next}
  - become visited
- else
  - send(return) to entry
  - send(visited) to N(x) - entry
  - become done

Procedura visit (già mandato il visited)
- if unvisited non vuoto then
  - next = unvisited
  - send(T) to next
- else
  - if not initiator then
    - send(return) to entry
  - become done
