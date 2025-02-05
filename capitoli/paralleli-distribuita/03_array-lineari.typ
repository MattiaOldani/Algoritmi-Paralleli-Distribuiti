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

= Array lineari

La prima architettura parallela a memoria distribuita che vediamo sono gli *array lineari*. Questa architettura è formata da $n$ processori $P_i$ collegati in sequenza. I parametri di questa rete sono:
- *grado* $gamma = 2$, ottimo per la realizzazione;
- *diametro* $delta = n - 1$, lower bound per Max quindi non sono soddisfatto;
- *ampiezza di bisezione* $beta = 1$.

Ricordiamoci che sulla PRAM avevamo:
- Max risolto con $p(n) = n/log(n)$ processori in tempo $T = log(n)$;
- Ordinamento risolto con $p(n) = n$ processori in tempo $T = log(n)$.

== Shuffle

La prima primitiva che vogliamo trovare è *shuffle*.

Per ora noi sappiamo fare molto bene lo *swap contiguo*, ovvero il processore $P_k$ deve avere il dato $A[k+1]$ mentre il processore $P_(k+1)$ deve avere il dato $A[k]$.

Avrò bisogno di $3$ passi paralleli:
- doppia send per mandare:
  - $A[k]$ a $P_(k+1)$;
  - $A[k+1]$ a $P_k$;
- doppia receive per ricevere il dato;
- assegnare i dati appena ricevuti.

Il problema shuffle:
- prende in *input* un numero pari di valori $A[1], dots, A[s], A[s+1], dots, A[2s]$;
- restituisce in *output* la sequenza $A[1], A[s+1], A[2], A[s+2], dots, A[s], A[2s]$.

Ci servirà l'operazione di swap che abbiamo appena visto: l'idea per l'algoritmo parallelo scambia i due elementi centrali, poi i due elementi appena a sinistra/destra, poi eccetera.

Questo albero di swap contigui ci richiedono $p(s) = 2(s-1)$ processori con un utilizzo di tempo $T(s,p(s)) = 3(s-1)$. Il migliore algoritmo sequenziale richiede tempo $Theta(s^2)$, quindi l'efficienza vale $ E = frac(s^2, 2(s-1) dot 3(s - 1)) = C eq.not 0 . $

== Max

Per la primitiva *max* dobbiamo mandare il dato di un certo processore a tutti gli altri. La primitiva *SEND* esegue un numero di passi uguale alla distanza $d(i,j)$ tra i due nodi, e questa distanza è proprio un costo del problema.

Un processore $P_i$, per mandare un dato al processore $P_j$, effettua una SEND, poi avvengono una serie di RECEIVE-SEND, e infine $P_j$ effettua una RECEIVE. Il numero totale di operazioni è $ 2d(i,j) = 2 abs(i-j) . $

La prima cosa che notiamo è che la trasmissione di un dato non è più costante, come nelle PRAM.

Il problema Max:
- prende in *input* una serie di valori $A[1], dots, A[n]$;
- restituisce in *output*, nel processore $P_n$, il valore $max{A[i] bar.v 1 lt.eq i lt.eq n}$.

Il tempo per Max su array lineari è limitato inferiormente da $delta = n - 1$, che è ben peggiore del tempo $log(n)$ che avevamo prima nelle PRAM.

L'idea per un algoritmo parallelo per Max considera l'algoritmo sommatoria delle PRAM e cerca di abbassare il numero di processori per averne $log(n)$. Come facciamo?

Al $j$-esimo passo confrontiamo i numeri a distanza $2^(j-1)$, selezioniamo il massimo e lo memorizziamo nel processore di indice massimo. Il numero di passi che eseguiamo è $log(n)$.

#align(center)[
  #pseudocode-list(title: [*Max parallelo*])[
    + for $j = 1$ to $log(n)$
      + for $k in {2^j t - 2^(j-1) bar.v 1 lt.eq t lt.eq n/2^i}$ par do
        + $"Send"(k, k + 2^(j-1))$
      + for $k in {2^j t bar.v 1 lt.eq t lt.eq n/2^j}$ par do
        + if $(A[k] < A[k - 2^(j-1)])$ then
          + $A[k] = A[k - 2^(j-1)]$
  ]
]

Vediamo il tempo impiegato dalle due fasi:
- la fase di *send* è $2$ volte la distanza tra i processori, quindi $2 dot 2^(j-1) = 2^j$;
- la fase di *compare* vale $2$, perché faccio solo un confronto e un assegnamento.

Il tempo che abbiamo appena visto deve essere eseguito per ogni passo $j$, quindi $ sum_(j = 1)^(log(n)) 2^j + 2 &= sum_(j = 1)^log(n) 2^j + 2 log(n) = frac(2^(log(n) + 1) - 1, 2 - 1) underbracket(quad -1 quad, "non parto da" 0) + 2 log(n) = \ &= 2n - 2 + 2log(n) = O(n) . $

Utilizzando $p(n) = n$ processori, l'efficienza vale $ E = frac(n, n dot n) arrow.long 0 . $

Questo non ci piace: riduciamo il numero di processori da $n$ a $p$. Con questo accorgimento operiamo sul parametro $delta$ della nostra rete, visto che non abbiamo più $n$ processori in fila ma $p$. Ogni processore ora prende $n/p$ elementi, sui quali viene calcolato il Max sequenziale in tempo $n/p$. Su questi massimi poi viene eseguito Max parallelo.

I processori ora sono $p(n) = p$, utilizzati in tempo $T(n,p(n)) = O(n/p) + O(p)$. L'efficienza vale $ E = frac(n, p (n/p + p)) = frac(n, n + underbracket(p^2, n)) = 1/2 eq.not 0 . $

Per avere questa efficienza dobbiamo imporre $n = p^2$, ovvero $p = sqrt(n)$.

Con questo valore di $p$, i processori sono $p(n) = sqrt(n)$ e il tempo è $T(n,p(n)) = O(sqrt(n))$.

== Ordinamento

Per risolvere *ordinamento* ci serve una primitiva di swap che lavora tra due processori generici, e non contigui come nella shuffle. Qua abbiamo diverse opzioni per questa primitiva.

La prima soluzione (_peggiore_) esegue due send in sequenza, una $(i,j)$ e una $(j,i)$, e poi un assegnamento parallelo. Questo viene eseguito in tempo $T(n,p(n)) = 4d(i,j) + 1$, non va bene.

La seconda soluzione (_mid_) esegue le send in simultaneo, ma qui abbiamo due casi:
- se la distanza tra i processori è *dispari*, ovvero è $2k+1$, i processori impiegati sono $2k+2$, divisi in due metà da $k+1$ processori. I processori centrali hanno indici $k+1$ e $k+2$, che ricevono in simultanea i dati dai due bordi. La send tra questi due processori avviene in simultaneo, tanto abbiamo delle connessioni full duplex, e poi mandiamo i dati ricevuti ai bordi.
- se la distanza tra i processori è *pari*, ovvero è $2k$, i processori impiegati sono $2k + 1$, divisi in due metà da $k$ processori con un processore di indice $k + 1$ centrale. La send dai bordi fino al processore $k + 1$ arrivano in contemporanea, ma la receive è sequenziale quindi impiega tempo $2$ prima di poter mandare i dati ricevuti ai bordi.

Il tempo nel primo caso è $ T(n,p(n)) = 2k + 2 + 2k + 1 = 4k + 2 + 1 = 2(2k + 1) + 1 = 2d(i,j) + 1 $ mentre nel secondo caso il tempo è $ T(n,p(n)) = 2k + 1+ 2k + 1 + 1 = 4k + 3 = 2(2k) + 3 = 2d(i,j) + 3 . $

L'altra primitiva per l'ordinamento che ci serve è il *minmax* tra celle contigue, che assegna al processore di indice minimo il valore minimo e al processore di indice massimo il valore massimo. Questa primitiva in poche parole implementa il comportamento di un *confrontatore*, ovvero $ P_k = min{A[k], A[k+1]} and P_(k+1) = max(A[k], A[k+1]) . $

Ricordiamoci che la MinMax ha $5$ come costo del passo parallelo.

Il problema ordinamento:
- prende in *input* una serie di valori $A[1], dots, A[n]$ assegnati ai processori $P[1], dots, P[n]$;
- restituisce in *output* i valori dei processori ordinati in senso crescente.

Usiamo una sorting network chiamata *ODD/EVEN*. Numeriamo le righe dei dati dall'alto a partire da $1$. La SN ha esattamente $n$ step di confrontatori, formati da un'alternanza di colonne di confrontatori dispari a colonne di confrontatori pari. Un *confrontatore dispari* è un confrontatore che inizia su una riga dispari e finisce sulla riga pari sottostante. Un *confrontatore pari* ha la definizione analoga ma adattata.

Qua sotto vediamo un esempio di ODD/EVEN per una rete di grandezza $n = 5$.

#v(12pt)

#figure(image("assets/03_ordinamento.svg", width: 65%))

#v(12pt)

#theorem()[
  ODD/EVEN è corretto.
]

#proof()[
  La dimostrazione viene fatta con il *principio 01*.

  Diamo ${0,1}^n$ in pasto ad ODD/EVEN, ottenendo $0^j 1^e$ tale che $j + e = n$, facendo esattamente $n$ round di confrontatori.

  Nel caso peggiore, avendo tutti gli $1$ ad inizio sequenza, ogni $1$ deve scendere di $n - e = j$ posizioni. Inoltre, prima di effettuare la discesa, ogni $1$ fa anche un "_ritardo_" (*_momento Trenord_*) in base alla sua posizione $i$ nella sequenza.

  Il numero di passi impiegato è al massimo $n - e + i$, ma visto che $i lt.eq e$ otteniamo al più $ n - e + e = n $ passi. Ma allora $n$ passi sono necessari e sufficienti.
]

Il numero di passi è necessario (_visto nell'esempio che non ho messo_) e sufficiente (_dimostrazione_).

Il tempo per implementare questo algoritmo sequenzialmente è $T(n) = n dot n/2 approx n^2$.

Per l'implementazione parallela vediamo l'idea di *Haberman* del $1972$.

#align(center)[
  #pseudocode-list(title: [*Ordinamento parallelo*])[
    + for $i = 1$ to $n$
      + for $k in {2t - (i space % space 2) bar.v 1 lt.eq t lt.eq n/2}$ par do
        + $"MinMax"(k,k+1)$
  ]
]

Stiamo utilizzando $p(n) = n$ processori in tempo $T(n,p(n)) = 4n$. L'efficienza vale $ E = frac(n log(n), n dot 4n) arrow.long 0 . $

Ricordiamoci che con $beta = 1$ il minimo tempo per l'ordinamento è $n/2$, e questo non va bene perché noi stiamo eseguendo con tempo $n$. Riduciamo i processori a $p$ con il *principio di Wyllie*: ogni processore ora prende $n/p$ dati e li ordina sequenzialmente in un tempo $O(n/p log(n/p))$.

Questa versione dell'algoritmo è una versione che non usa minmax ma *merge-split*. Questa operazione avviene tra due processori contigui e agisce come segue:
- entrambi i processori ricevono $n/p$ dati e li ordinano in tempo $O(n/p log(n/p))$:
- il processore di SX spedisce $n/p$ dati ordinati al processore di DX in un tempo $O(n/p)$;
- il processore di DX riceve e fonde (_merge_) i nuovi dati con i suoi $n/p$ ordinati in tempo $O(n/p)$;
- il processore di DX invia (_split_) gli $n/p$ dati più piccoli al processore di SX in un tempo $O(n/p)$.

#align(center)[
  #pseudocode-list(title: [*Ordinamento parallelo con merge-split*])[
    + for $i = 1$ to $p$
      + for $k in {2t - (i space % space 2) bar.v 1 lt.eq t lt.eq p/2}$ par do
        + $"MergeSplit"(k,k+1)$
  ]
]

Usando $p(n) = p$ processori con tempo $T(n,p(n)) = n/p log(n/p) + p dot n/p = n/p log(n/p) + n$, l'efficienza che otteniamo vale $ E = frac(n log(n), p dot (n/p log(n/p) + n)) = frac(n log(n), n log(n/p) + underbracket(quad n p quad, n log(n))) = C eq.not 0 . $

Per avere questo dobbiamo imporre $n p = n log(n)$ e quindi $p = log(n)$.

Il tempo rimane comunque un $O(n)$ perché la riduzione dei processori abbassa il diametro del grafo ma non modifica l'ampiezza di bisezione, che rimane sempre $beta = 1$.
