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

= Broadcasting

Usiamo due stati S = {iniziatore, inattivo}. Abbiamo Sinit = stati delle entità in C(0) e Sterm = stati delle entità in C(f)

Pinit una entità tiene I: $ exists x in E bar.v "valore"(x) and forall y eq.not x quad "valore"(y) = emptyset.rev $

Pfinal: tutte le entità ce l'hanno, ovvero $ forall x in E quad "valore"(x) = I $

== Prima versione

// FOTO DEL PROTOLLO

S = {iniziatore, inattivo}, Sinit = {iniziatore, inattivo} e Sfinal = {inattivo}

Iniziatore, se ricevo impulso spontaneo
- send(M) to N(x)
- become inattivo

Inattivo, se ricevo M
- processa M (preleva informazione e mettila in valore)
- send(M) to N(x)

Il messaggio è $M = (t, o, d, I)$ con $t$ tipologia del mex, o e d sono origine e destinatario, I informazione

Abbiamo un problema

Problema dell'altra volta: protocollo corretto ma non termina, perché dopo lo stato iniziale tutto diventa inattivo e gli inattivi ricevono, processano e mandano ancora in giro. Non funziona anche se modifichiamo imponendo di non mandare a chi me l'ha mandato.

Infatti Futuro(t) non è mai il vuoto, la computazione non termina

Modifichiamo gli stati: Sstart subset Sinit stati che fanno iniziare il protocollo, mentre Sfinal subset Sterm stati per cui la sola azione possibile è quella nulla

Abbiamo ora Sinit = {iniziatore, inattivo}, Sstart = {iniziatore}, Sterm e Sfinal = {inattivo}

Grazie a questo stato il protocollo termina

La soluzione per $P$ è tale che $ forall C(0) in "Pinit" quad exists t' bar.v forall t > t' quad C(t) in "Pfinal" ("correttezza") $ e anche $ forall x in E quad "stato"_t  (x) in "Sfinal" ("terminazione") $

== Seconda versione [flooding]

Abbiamo S = {iniziatore, inattivo, finito}, Sstart = {iniziatore}, Sfinal = {finito}

Abbiamo iniziatore con impulso spontaneo
- send(M) to N(x)
- become finito

Abbiamo inattivo con ricezione di M
- processa M
- send M to N(x)-sender
- become finito

Le coppie stato x evento non indicano fanno nil

Vediamo la complessità:
- M[F] = $sum_(x in E) (N(x) - 1) + underbracket(1, "iniziatore") = 2m - n + 1$
- T[F] $lt.eq d$ diametro della rete

Abbiamo anche lower bound:
- T[broadcast / RI] gt.eq d, tempo causale (caso peggiore)
- M[broadcast / RI] gt.eq m per un teorema

Il protocollo è ottimale

#theorem()[
  M[broadcast / RI] gt.eq m
]

#proof()[
  Per assurdo, risolvo il problema con meno di m messaggi. Sia $A$ il protocollo che non manda messaggi su $(x,y)$. $A$ è corretto e deve lavorare bene su ogni $G$, quindi anche $G'$ ottenuto da $G$ mettendo un nuovo nodo $z$ non iniziatore, tolgo arco xy e aggiungo xz e zy con $ lambda_x (x,z) = lambda_x (x,y) $ e $ lambda_y (y,z) = lambda_y (y,x) $

  Se eseguo $A$ su $G'$ allora $z$ non riceve mai il messaggio $I$ quindi $A$ non è corretto.
]

== Problema wake-up

Broadcast parto da una e mando a tutti, in wake-up è generale, ho tot entità attive che devono mandare. Rilassiamo il vincolo unico iniziatore quindi.

Protocollo wFlood, ho S = {dormiente, attivo}, Sinit = Sstart = {dormiente}, Sterm = Sfinal = {attivo}

Se dormiente e impulso spontaneo faccio
- send(W) to N(x)
- become attivo

Se dormiente e ricevo W
- send(W) to N(X) - sender
- become attivo

Il resto è nil

Costi di sta roba:
- T[wFlood] lt.eq d
- 2m - n + 1 lt.eq M[wFlood] lt.eq 2m (1 entità e tutte le entità)
