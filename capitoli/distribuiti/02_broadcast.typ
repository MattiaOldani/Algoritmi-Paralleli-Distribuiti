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

= Broadcasting

Per il problema *broadcasting* vogliamo spargere l'informazione presente in una entità in tutte le altre presenti nella rete.

Definiamo $pinit$ la proprietà che indica che una sola entità contiene l'informazione $I$: $ exists x in E bar.v valore(x) = I \ and \ forall y eq.not x in E quad space valore(y) = emptyset.rev . $

Definiamo anche $pfinal$ la proprietà che indica che tutte le entità contengono l'informazione $I$: $ forall x in E quad valore(x) = I . $

== Prima versione

Vediamo una prima versione del *PROTOLLO* per broadcast.

#v(12pt)

#figure(image("assets/02_protollo.png", width: 50%))

#v(12pt)

Per questo protollo andiamo ad usare:
- *stati* $S = {"iniziatore", "inattivo"}$;
- *stati iniziali* $sinit = {"iniziatore", "inattivo"}$;
- *stati terminali* $sterm = {"inattivo"}$.

Definiamo anche le *regole* che devono seguire le nostre entità.

#align(center)[
  #pseudocode-list(title: [*Iniziatore*])[
    + Se riceve un impulso spontaneo
      - $send(M)$ to $N(x)$
      - become inattivo
  ]
]

#align(center)[
  #pseudocode-list(title: [*Inattivo*])[
    + Se riceve $M$
      - processa $M$ (_preleva le informazioni_)
      - $send(M)$ to $N(x)$
  ]
]

Il messaggio è nella forma $ M = (t, o, d, I), $ formato dai campi:
- $t$ *tipologia* del messaggio;
- $o$ e $d$ entità *origine* e entità *destinatario*;
- $I$ *informazione*.

Questa prima versione ha un problema: *non termina mai*. Infatti, ogni stato diventa inattivo dopo l'impulso iniziale e questi, ogni volta che ricevono qualcosa, anche se già ce l'hanno, la mandano ai loro vicini. Vediamo alcune modifiche che possiamo fare.

Imporre di non mandare il messaggio a chi ce l'ha mandato non modifica il comportamento.

Per rendere $futuro(t)$ vuoto ad un certo punto, modifichiamo gli stati:
- definiamo $sstart subset.eq sinit$ insieme degli stati che fanno iniziare il protollo;
- definiamo $sfinal subset.eq sterm$ insiemi degli stati che eseguono solo l'azione nulla.

I nostri *stati* ora diventano:
- $sinit = {"iniziatore", "inattivo"}$;
- $sstart = {"iniziatore"}$;
- $sterm = sfinal = {"finito"}$.

Con questo nuovo stato terminale riusciamo a far terminare la computazione.

La soluzione che abbiamo costruito è *corretta* e *termina*. Cosa vogliono dire questi due termini?

Un problema è *corretto* se $ forall C(0) in pinit quad exists t' bar.v forall t > t' quad C(t) in pfinal $ ovvero ogni configurazione iniziale che rispetta i propri predicati, da un certo $t$ in poi, finisce in una configurazione finale che rispetta i propri predicati.

Un problema *termina* se $ exists t bar.v forall x in E quad rstatot(x,t) in sfinal $ ovvero esiste un istante di tempo nel quale tutte le entità sono in uno stato finale.

== Seconda versione [flooding]

Una versione migliore sfrutta la tecnica del *flooding*.

Abbiamo a disposizione i seguenti *stati*:
- $S = {"iniziatore", "inattivo", "finito"}$;
- $sstart = {"iniziatore"}$;
- $sinit = {"iniziatore", "inattivo"}$;
- $sfinal = sterm = {"finito"}$.

#align(center)[
  #pseudocode-list(title: [*Iniziatore*])[
    + Se riceve impulso spontaneo
      - $send(M)$ to $N(x)$
      - become finito
  ]
]

#align(center)[
  #pseudocode-list(title: [*Inattivo*])[
    + Se riceve $M$
      - processa $M$ (_preleva le informazioni_)
      - $send(M)$ to $N(x) - {sender}$
      - become finito
  ]
]

Non l'abbiamo detto, ma le regole sono delle *funzioni totali*: infatti, se non definiamo un'azione per una coppia stato+evento allora la funzione di default esegue *nil*.

Il *numero di messaggi* è $ M["flooding"] = sum_(x in E) (N(x) - 1) + underbracket(quad 1 quad, "iniziatore") = 2m - n + 1 . $

Il *tempo* impiegato è $ T["flooding"] lt.eq d $ perché nel caso peggiore l'iniziatore è nel nodo che definisce il diametro della rete.

Abbiamo anche dei *lower bound* per questo problema.

#theorem()[
  Vale $ M["broadcast" slash "RI"] gt.eq m . $
]

#proof()[
  Supponiamo per assurdo di poter risolvere broadcast con meno di $m$ messaggi totali. Sia $A$ questo protollo. Supponiamo che $A$ non mandi mai messaggi sull'arco $(x,y)$ del grafo $G$.

  Il protollo $A$ è corretto, quindi lavora bene su ogni grafo. Creiamo $G'$ a partire da $G$:
  - aggiungendo un nodo $z$ non iniziatore;
  - togliendo l'arco $(x,y)$;
  - aggiungendo gli archi $(x,z)$ e $(z,y)$ con etichette $lambda_x (x,z) = lambda_x (x,y)$ e $lambda_y (y,z) = lambda_y (y,x)$.

  Se eseguo $A$ su $G'$ allora $z$ non riceve mai il messaggio $I$, quindi $A$ non è corretto.
]

Il tempo invece ha il seguente lower bound: $ T["broadcast" slash "RI"] gt.eq d . $ Questo è il *tempo causale*, ovvero il tempo nel caso peggiore.

Visti questi risultati, il protollo che abbiamo costruito è ottimale.

== Problema wake-up

Il problema del *wake-up* è una versione generale del broadcast: in quest'ultimo partiamo con l'informazione in una sola entità, nel wake-up rilassiamo il vincolo di avere un unico iniziatore.

Useremo il protocollo *w-flood*, che utilizza i seguenti *stati*:
- $S = {"dormiente", "attivo"}$;
- $sinit = sstart = {"dormiente"}$;
- $sfinal = sterm = {"attivo"}$.

Vediamo le *regole* per questa versione rilassata di broadcast.

#align(center)[
  #pseudocode-list(title: [*Dormiente*])[
    + Se riceve impulso spontaneo
      - $send(W)$ to $N(x)$
      - become attivo
    + Se riceve $W$
      - $send(W)$ to $N(x) - sender$
      - become attivo
  ]
]

Come prima, il *tempo* impiegato è $ T["w-flooding"] lt.eq d , $ mentre il *numero di messaggi* spediti è $ underbracket(2m - n + 1, "un iniziatore") lt.eq M["w-flooding"] lt.eq underbracket(quad 2m quad, n "iniziatori") . $
