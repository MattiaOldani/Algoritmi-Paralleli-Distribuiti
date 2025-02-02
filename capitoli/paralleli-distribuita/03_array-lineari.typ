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

= Array lineari

Architettura parallela a memoria distribuita. Ci sono $n$ processori $p_1, dots, p_n$ collegati su una riga. I parametri di questa rete sono:
- $gamma = 2$ grado del grafo (ottimo per la realizzazione)
- $delta = n - 1$ diametro (lower bound per max, non sono soddisfatto perché sequenziale ci mette $n$)
- $beta = 1$ ampiezza di bisezione (lower bound per ordinamento)

Sulla PRAM abbiamo max che usa $p = n/log(n)$ e $T = log(n)$ mentre per ordinamento abbiamo $p = n$ e $T = log(n)$ (per Cole) quindi dobbiamo abbassare i processori.

Problemi che affronteremo sono shuffle, max e ordinamento

Abbiamo una serie di processori $P_n$ che tengono i dati $A[n]$. Se servono dati di altri li chiedono.

Vediamo la primitiva per shuffle.

Per risolvere shuffle facciamo swap contiguo, ovvero swap(k,k+1). Ovvero devo avere Pk con A[k+1] e Pk+1 con A[k]

Avrò bisogno di 3 passi paralleli, ovvero doppia send per mandare, doppia receive per ricevere e poi assegnare A[k]=A[k+1] e A[k+1]=A[k]

Vediamo shuffle

In input ho $A[1], dots, A[s], A[s+1], dots, A[2s]$ di lunghezza pari, e in output voglio $A[1], A[s+1], A[2], A[s+2], dots, A[s], A[2s]$ ovvero voglio primo elemento prima metà + primo seconda metà, poi secondo elemento, poi terzo, eccetera.

Idea: scambio a metà, poi quelli vicini, poi vicini ancora, eccetera. Creo un albero di swap contigui

Il numero di processori è $2(s-1)$ e il tempo parallelo è $3(s-1)$. Un algoritmo sequenziale per questo è $Theta(s^2)$ (senza memoria, sennò $n$) quindi $ E = frac(s^2, s s) = C eq.not 0 $ quindi mega ottimale cazzo

Vediamo massimo MAX

Dobbiamo mandare dati ai vari processori. Se devo mandare da i a j devo fare SEND(i,j), lo faccio in un numero di passi d(i,j), entra nel costo del problema. Quindi faccio send, poi receive-send, poi solo receive in j.

In totale sono 2d(i,j) = 2 abs(i-j)

Vediamo come la trasmissione non è più costante come nelle PRAM

In input ho $A[1], dots, A[n]$ e vogliamo in $P_n$ il valore $ max{A[i] bar.v 1 lt.eq i lt.eq n} $

Il tempo per MAX su array lineari è limitato inferiormente da $n$, mentre sulle PRAM era $log(n)$. Il sequenziale invece $n$.

Idea:
- si considera l'algoritmo per sommatoria delle PRAM
- riduciamo i processori per abbassare $Theta(n)$ su array a $n$ processori

Al $j$-esimo passo confrontiamo i numeri a distanza $2^(j-1)$, selezioniamo il massimo e lo memorizziamo nel processore $2^j t$

Il numero di passi è $log(n)$. Confronto ogni volta $2_j t - 2^(j-1)$

Vediamo il codice $ &"for" j = 1 "to" log(n) \ &quad "for" k in {2^j t - 2^(j-1) bar.v 1 lt.eq t lt.eq n/2^j} "par do" \ &quad quad "SEND"(k,k+2^(j-1)) \ &quad "for" k in {2^j t bar.v 1 lt.eq t lt.eq n/2^j} "par do" \ &quad quad "if" (A[k] < A[k-2^(j-1)]) "then" \ &quad quad quad A[k] = A[k - 2^(j-1)] $

Fase di send e fase di compare

Vediamo il tempo:
- send è due volte la distanza tra i processori, quindi ho $2 2^(j-1) = 2^j$ per $j = 1, dots, log(n)$
- compare vale $2$, solo confronto e assegnamento, ma sempre per $j = 1, dots, log(n)$

Quindi il totale è $ sum_(j = 1)^(log(n)) 2^j + 2 = sum_(i=1)^log(n) 2^j + 2 log(n) = 2^(log(n) + 1) - 1 underbracket(- 1, "parto da" 0) + 2 log(n) = 2n - 2 + 2log(n) = O(n) . $

Ho $n$ processori, quindi $E arrow.long 0$ non va bene

Riduciamo i processori da $n$ a $p$ in questo modo operiamo sul parametro $delta$ distanza massima tra i processori. Ogni processore prende $n/p$ elementi e non più uno. Ora ho array di $p$ elementi e quindi cambia anche $delta$ che si riduce.

Nuovo algoritmo:
- un processore seleziona il max sequenziale tra i suoi $n/p$ numeri
- si esegue MAX su $p$ processori

Prestazioni:
- processori $p$
- tempo $O(n/p) + O(p)$

Efficienza ho numeratore $n$ e denominatore $ p(O(n/p) + O(p)) = O(n) + O(p^2) = O(n) $

Vorremmo $p^2 = n$ per avere $O(n)$ e semplificare, quindi $ p = sqrt(n) $ per avere efficienza non nulla

Quindi MAX lo risolviamo bene su array lineari con $p = sqrt(n)$ e tempo $T = (O(n / sqrt(n))) + O(sqrt(n)) = O(sqrt(n))$

Vediamo invece ordinamento

Abbiamo bisogno di swap tra due processori generici, non più contigui. Scambiamo Pi e Pj, abbiamo diverse soluzioni

USO LA SEND, quindi devo fare una send i,j POI una send j,i, poi alla fine di tutto assegnamento

Il tempo è 2d(i,j) + 2d(j,i) + 1 = 4d(i,j) + 1 ma tempo brutto

USO LA SEND SIMULTANEA abbiamo due casi:
- distanza tra i processori dispari 2k+1 ovvero i processori sono pari 2k+2, divisi a metà k+1 processori. Quelli in mezzo sono k+1 e k+1+1. I dati dai bordi arrivano simultanei con send(i,k+1) e send(j,k+i+1), poi faccio send simultanea (ho un full duplex) e poi le send opposte
- distanza tra i processori pari: come esercizio

Il tempo del primo caso è 2k (distanza bordi) + 2 + 2k (send di nuovo) + 1 (assegnamento) = 4k+3 = 2(2k + 1) + 1 = 2d(i,j) + 1

Il tempo nel secondo caso è 2d(i,j) + 3

Altra primitiva per l'ordinamento che ci serve è minmax, ovvero processore di indice minimo metto valore minimo, processore di indice massimo metto valore massimo

In poche parole implementa il confrontatore, ovvero $P_k = min{A[k], A[k+1]}$ e altro bla bla bla

La minmax ha 4 come costo del passo parallelo.

Ordinamento ha in input $A[1], dots, A[n]$ assegnati ai processori $P_1, dots, P_n$ e in output voglio cont(P_1) < dots < cont(P_n)

Diamo un algoritmo test/swap obliovius descritto da una SN, si chiama ODD/EVEN sorting network.

Abbiamo una colonna di confrontatori dispari (sopra è su un dispari) seguita una colonna di confrontatori pari. Una colonna si chiama round perché è un passo parallelo. Alterno per $n$ volte questi confrontatori.

Per la correttezza di ODD/EVEN usiamo il principio 0/1, ovvero $ {0,1}^n arrow.long.squiggly "ODD/EVEN" arrow.long.squiggly 0^j 1^e quad bar.v quad j + e = n $ a patto di fare esattamente $n$ round.

Ogni $1$ deve scendere di $n-e=j$ posizioni. Contiamo gli uni a partire da 1 a partire dal basso. Vediamo quanto ci mettono a scednere di $j$ posizioni. Notiamo che $i$ ha $i$ ritardi e poi scende di $j$ posizioni. Quindi il primo uno che abbiamo ci mette $j + i$, ma $i$ è esattamente il numero di 1 dell'input, è il ritardo.

Regola: l'$i$-esimo uno dal basso impiega $n - e + i$ passi per posizionarsi correttamente.In generale è un al più.

Dato che $i lt.eq e$ si ottiene $ n - e + underbracket(e, i "di prima") = n . $

Quindi $n$ passi sono necessari (visto dall'input) e sufficienti.

Implementazione sequenziale è $n n/2 approx n^2$

In parallelo usiamo Haberman del 1972

Abbiamo $n$ passi paralleli o round di confrontatori paralleli con minmax(k,k+1)

#align(center)[
  #pseudocode-list()[
    + for $i = 1$ to $n$
      + for $k in {2t - (i % 2) bar.v 1 lt.eq t lt.eq n/2}$ par do
        + minmax(k,k+1)
  ]
]

Il tempo è $4n = O(n)$ mentre efficienza è $ frac(n log(n), n n) arrow.long 0 $ non va bene riduco i processori

Osservazione: per $n$ processori in un array lineare l'ordinamento vuole tempo $Omega(frac(n, 2 beta))$ e qui $beta = 1$ quindi ci mettevo $n$, non va bene

Riduco i processori a $p$ quindi ognuno prende $n/p$ dati e li ordina in sequenza in un tempo $O(n/p log(n/p))$

L'algoritmo è una versione che non usa minmax ma merge-split: avviene tra due processori contigui. Essa fa:
- processore di sinistra spedisce $n/p$ dati ordinati al processore di destra in un tempo $O(n/p)$
- il processore di destra riceve e fonde i nuovi $n/p$ dati con i suoi $n/p$ ordinati (operazione di merge) in tempo $O(n/p)$
- il processore di destra invia i dati più piccoli $n/p$ al processore di sinistra in un tempo $O(n/p)$ (operazione di split)

#align(center)[
  #pseudocode-list()[
    + for $i = 1$ to $p$
      + for $k in {2t - (i % 2) bar.v 1 lt.eq t lt.eq p/2}$ par do
        + merge-split(k,k+1)
  ]
]

Ogni primitiva di merge-split viene ripetuta $p$ volte

Il tempo parallelo è $n/p log(n/p) + p n/p = O(n)$. Il denominatore è $p (n/p log(n/p) + n) = n log(n/p) + n p$ e noi vogliamo che sia $n log(n)$ per avere una frazione uguale. Quindi prendiamo $p = log(n)$. Efficienza quindi $E arrow.long C eq.not 0$

Osserviamo come il tempo sia rimasto $O(n)$ ma abbiamo abbassato il tempo parallelo. Ciò si spiega in quanto la riduzione dei processori agisce sul diametro e non sull'ampiezza di bisezione, che rimane sempre $beta = 1$.

Possiamo migliorare questi costi
