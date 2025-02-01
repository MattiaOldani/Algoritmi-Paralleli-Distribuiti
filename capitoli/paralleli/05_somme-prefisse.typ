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

= Somme prefisse

Il problema delle somme prefisse userà il modulo della sommatoria.

Per questo problema abbiamo:
- *input*: $M[1], dots, M[n]$;
- *output*: $sum_(i=1)^k M[i] arrow.long M[k] quad 1 lt.eq k lt.eq n$.

Assumiamo $n$ potenza di $2$ per semplicità.

L'algoritmo sequenziale somma nella cella $i$ quello che c'è nella cella $i-1$.

#align(center)[
  #pseudocode-list(title: [Algoritmo sequenziale furbo])[
    + for $k = 2$ to $n$ do
      + $M[k] = M[k] + M[k-1]$
  ]
]

Il tempo di questo algoritmo è $n-1$.

== Prima versione

Vediamo una proposta parallela. Al modulo sommatoria passo tutti i possibili prefissi: un modulo somma i primi due, un modulo i primi tre, eccetera.

Ho un paio di problemi: il primo è che l'algoritmo non è EREW ma questo chill; il secondo problema è che ho un CREW su PRAM con $ p(n) lt.eq (n-1) n/log(n) = n^2 /log(n) = sum_(i=2)^n i/log(i) gt.eq 1/log(n) sum_(i=2)^n i approx n^2 / log(n) \ \ T(n,p(n)) = log(n) . $

Ma allora $ E = frac(n-1, n^2/log(n) log(n)) arrow.long 0 $ che è poco efficiente.

== Seconda versione [pointer doubling]

Usiamo il *pointer doubling*, di *Kogge-Stone* del $1973$.

Idea: si stabiliscono dei legami tra i numeri, ogni processore si occupa di un legame e ne fa la somma: il processore $i$ fa la somma tra $m$ e $k$ e lo mette nella cella di indice maggiore (_quella di k_).

All'inizio ho link tra la cella e la successiva.

Alla prima iterazione ho primo secondo, poi secondo terzo, eccetera. Poi aggiorno i link: lego una cella non con quella che avevamo prima ma con quella a distanza doppia. Prima 1, poi 2, poi 4, eccetera. Ovviamente alcuni processori non hanno dei successori.

Mi fermo quando non riesco a mettere archi, quindi alla fine non ho nessun successore.

Rispondiamo ad alcune domande:
- al passo $j$ quanti elementi senza successori ho: $2^j$;
- quanti passi dura l'algoritmo: se $2^j = n$ allora $j = log(n)$, ovvero termino quando ho esattamente $n$ elementi senza successori;
- quanti processori attivo al passo $j$: Sempre almeno uno, ma faccio sempre $1 lt.eq k lt.eq n - 2^(j-1)$;
- sia $S[k]$ il successivo di $M[k]$, come inizializzo $S$: Faccio $S[k] = k+1$ e $S[n] = 0$, perché all'inizio ho tutti i successori e poi l'ultimo che non ce l'ha;
- dato il processore $p_k$ quale istruzione su $M$ deve eseguire: $M[k] + M[S[k]] arrow.long M[S[k]]$;
- aggiornamento: $S[k] == 0 ? 0 : S[S[k]]$ faccio successore del successore.

#align(center)[
  #pseudocode-list(title: [Prima versione parallela])[
    + for $j=1$ to $log(n)$ do
      + for $1 lt.eq k lt.eq n - 2^(j-1)$ par do
        + $M[S[k]] = M[k] + M[S[k]]$
        + $S[k] = (S[k] == 0 ? 0 : S[S[k]])$
  ]
]

Competiamo per la stessa cella? No, siamo in EREW, accediamo alle stesse celle ma in momenti diversi.

Correttezza:
- è una EREW-PRAM perché $p_k$ lavora su $M[k]$ e $M[S[k]]$ e se $i eq.not j$ allora $S[i] eq.not S[j]$ quindi hanno successori diversi (solo se $S[i] = S[j] = 0$);
- dimostro che $M[k] = sum_(i=1)^k M[i]$. Dimostro che al $j$ esimo passo vale $ M[t] = cases(M[t] + dots + M[1] "se" t lt.eq 2^j, M[t] + dots + M[t - 2^j + 1] "se" t > 2^j) . $ Se questa è vera allora per $j = log(n)$ allora vale.

Per induzione su $j$:
- caso base $j=1$:
  - se $t lt.eq 2$ vedi $t=1,2$;
  - se $t > 2$ ho la seconda proprietà.
- vero $j-1$ dimostro per $j$. Al passo $j$ quanto vale $S$: $ S[k] = cases(k + 2^(j-1) "se" k lt.eq n - 2^(j-1), 0 "maggiore") . $ Le celle con indice $lt.eq 2^(j-1)$ proprietà vera per ipotesi. Le celle con indice:
  - $2^(j-1) lt.eq t lt.eq 2^j$ allora $t = 2^(j-1) + a$ e quindi $ M[a + 2^(j-1)] = ... ("non ho voglia") $
  - $t > 2^j$ ho $t = a + 2^j$, bla bla bla.

Valutazione:
- $p(n) = n-1$;
- il passo di aggiornamento di $M$ vale $5$ mentre il passo di aggiornamento di $S$ vale $4$, quindi $T(n,n-1) approx 9 log(n)$ (il log viene dal passo parallelo).

L'efficienza è quindi $ E(n,p(n)) = frac(n-1, (n-1) 9 log(n)) = frac(1, 9 log(n)) arrow.long 0 $ ma lentamente, non va bene.

Sfruttiamo Willye per far sparire $log(n)$ da sotto.

Mettiamo $p(n) = O(n/log(n))$ quindi a gruppi di log(n), avremo sempre tempo logaritmico ma andremo ad avere efficienza diversa da $0$.

Questo può essere usato come modulo per OP-prefissa, dove in output ho $ M[k] = "op"_(i=1)^k M[i] quad 1 lt.eq k lt.eq n $ operazione associativa come prima.
