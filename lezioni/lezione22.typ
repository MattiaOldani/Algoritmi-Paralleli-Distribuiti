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


= Lezione 22

== Spanning tree

Osservazione: broadcast, wp e tr sono Theta(m) con m = numero di link e n entità

Ma noi sappiamo che $ n - 1 lt.eq m lt.eq ... = O(n^2) $ ma n-1 è un albero e l'altro è un grafo completo. Noi non scegliamo la rete, possiamo costruire una sotto-rete

Perché importante? Strategia:
- al posto di usare tutta G usiamo una sottorete per minimizzare la complessità di comunicazione, quale sottorete? ALBERO

Attenzione ai costi:
- costruzione dell'albero
- costo originale sull'albero

Ad esempio, BD sull'albero è esattamente n-1 su alberi perché hai $ 2m - n + 1 = 2(n-1) - n + 1 = 2n - 2 - n + 1 = n - 1 $

Vogliamo costruire sottorete tale che
- coinvolge tutte le entità
- le entità sono connesse
- è priva di cicli

La soluzione distribuita richiede la conoscenza dell0albero all'interno della rete, ovvero ogni entità vedrà una piccole parte dell'albero (noi siamo migliori)

Definiamo $forall x in E$ la roba Tree-N(x) subset N(x), sottoinsieme di vicini che partecipano all'albero e che sono collegati direttamente a x

Diciamo che un arco (x,y) appartiene agli archi link(Tree-N(x)) se e solo se y sta in sta cosa. Link è un insieme di archi.

Infine, Tree è union di x in E di link(Tree-N(x))

Dobbiamo anche dire chi è la radice

Noi usiamo restrizioni RI con il protocollo Shout:
- ogni entità vede solo i suoi Tree-N(x) e tiene traccia del padre

La radice è l'entità che inizia il protocollo

Strategia Shout: CHIEDI!

Vediamo:
- la s(root) spedisce Q ai suoi vicini e attende le risposte
- ogni entità x diversa da s che riceve Q per:
  - la prima volta risponde YES e invia Q ai suoi vicini e si mette in attesa
  - una volta successiva alla prima risponde NO
- serve memorizzare l'entità padre e le entità che mi rispondono yes
- entità termina quando riceve tutte le risposte

In pratica è flooding con reply. Dobbiamo
- mandare messaggi Q yes no
- aggiornare variabili root, parent, tree-N(x), counter
- aggiornare lo stato per raggiungere la terminazione

Abiamo quindi
- stati iniziatore, inattivo, attivo, finito
- Sinit = {iniziatore, inattivo}
- Sterm = {finito}

Dobbiamo definire le azioni per iniz, inat e attivo

Iniziatore:
- se impulso spontaneo
  - root = true
  - counter = 0
  - tree-N(x) = vuoto
  - send(Q) to N(x)
  - become attivo

Inattivo
- se riceve Q
  - root = false
  - parent = sender
  - counter = 1
  - tree-N(x) = sender
  - send yes to sender
  - if counter = |N(x)| then
    - become finito
  - else
    - send(Q) to N(x) - sender
    - become attivo

Attivo
- se ricevo Q
  - send no to sender
- se riceve yes
  - Tree-N(x) U= {sender}
  - counter += 1
  - if counter == |N(x)| then
    - become finito
- se riceve no
  - counter += 1
  - if counter == |N(x)| then
    - become finito

Correttezza di Shout
- terminazione: in assenza di errori ricevuto un numero di risposte pari ai Q inviati, diventando finito
- tutte le entità sono presenti, grazie al flooding di Q
- le entità sono connesse: grazie al fatto che al primo Q rispondo con yes
- è priva di cicli: ogni entità risponde yes una e una sola volta, tranne la radice che risponde sempre no

Vediamo i costi:
- M[Shout] = 2 M[flooding] (Q + risposta) = 2[2m - (n-1)] circa 4m
- T[Shout] = T[flooding] + 1 lt.eq d + 1 (+1 è risposta ultimo Q)

I lower bound sono:
- M[SPT / RI] gt.eq m
- T[SPT / RI] gt.eq d

Vediamo Shout++: posso eliminare qualche messaggio? Per il tempo ci siamo, i messaggi non tanto

Yes si tengono, sono necessari, quelli no li cancelliamo. Questo perché se prendo no vuol dire che il bro ha già ricevuto un Q, quindi mi basta vedere un Q e interpretarlo come no

Se la risposta è no ho già ricevuto un Q a cui ha detto si, inviano altri Q in giro, quindi se ricevuto un Q lo interpreto come no e basta

Nuovo costo è 2m, un q in una direzione e nell'altra yes oppure q, quindi M[Shout++] = 2m (q-q o q-yes)

Altra soluzione usa il protocollo traversal, che però costruisce l'albero in sequenza, e a noi piace in parallelo. Tree sono i link su cui viaggiano i return (solo un padre)
