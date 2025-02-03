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

= Architetture parallele

Prima di vedere l'architettura parallela che ci accompagnerà durante tutta questa parte del corso, diamo una brevissima introduzione delle due architetture principali che possiamo utilizzare quando ci troviamo in un ambiente di calcolo parallelo.

== Memoria condivisa

L'architettura a *memoria condivisa* utilizza una memoria centrale che permette lo scambio di informazioni tra un numero $n$ di processori, ognuno dei quali possiede anche una _"memoria personale"_, formata da registri. Un *clock* centrale e comune coordina tutti i processori, che comunicano attraverso la memoria centrale in tempo costante $O(1)$, permettendo quindi una forte parallelizzazione.

== Memoria distribuita

L'architettura a *memoria distribuita* utilizza una rete di interconnesione centrale che permette lo scambio di informazioni tra un numero $n$ di processori, ognuno dei quali possiede anche una _"memoria personale"_, formata da registri. Un *clock* centrale e comune coordina tutti i processori, che comunicano attraverso la rete di interconnesione in un tempo che dipende dalla distanza tra i processori.

== Modello PRAM

Vediamo finalmente l'architettura che ci accompagnerà durante tutte questa parte del corso.

=== Struttura

Il *modello PRAM* (_Parallel RAM_) utilizza una memoria $M$ formata da registri $M[i]$ e una serie di processori $P_i$ che si interfacciano con essa. Ogni processore $P_i$ è una *RAM sequenziale*, ovvero contiene una unità di calcolo e una serie di registri $R[i]$.

La comunicazione avviene con la memoria centrale $M$ tramite due primitive che lavorano in tempo costante. Esse sono *LOAD* e *STORE*, usate rispettivamente per caricare un dato dalla memoria e salvare un dato nella memoria.

Le operazioni di ogni processore avvengono invece in locale, cioè con i dati della propria memoria privata. Il tempo di ogni processore $P_i$ è scandito da un clock centrale, che fa eseguire ad ogni processore la _"stessa istruzione"_ $istr(i)$.

Infatti, andiamo a definire il *passo parallelo* nel seguente modo

#align(center)[
  #pseudocode-list(title: [*Passo parallelo*])[
    + for all $i in II$ par do
      + $istr(k)$
  ]
]

Il passo parallelo fa eseguire a tutti i processori con indice in $II$ la $k$-esima istruzione, altrimenti fa eseguire una *nop*, l'operazione nulla.

L'istruzione eseguita dipende dal tipo di architettura:
- *SIMD* (_Single Instruction Multiple Data_) indica l'esecuzione della stessa istruzione ma su dati diversi;
- *MIMD* (_Multiple Instruction Multiple Data_) indica l'esecuzione di istruzioni diverse sempre su dati diversi.

Abbiamo diverse architetture anche per quanto riguarda l'accesso alla memoria:
- *EREW* (_Exclusive Read Exclusive Write_) indica una memoria con lettura e scrittura esclusive;
- *CREW* (_Concurrent Read Exclusive Write_) indica una memoria con lettura simultanea e scrittura esclusiva;
- *CRCW* (_Concurrent Read Concurrent Write_) indica una memoria con lettura e scrittura simultanee.

Per quanto riguarda la scrittura simultanea, abbiamo diverse modalità:
- *common*: i processori possono scrivere solo se scrivono lo stesso dato;
- *random*: si sceglie un processore a caso;
- *max/min*: si sceglie il processore con il dato massimo/minimo;
- *priority*: si sceglie il processore con priorità maggiore.

La politica EREW è la più semplice, ma si può dimostrare che $ "Algo(EREW)" arrow.long.double.l.r "Algo(CREW)" arrow.long.double.l.r "Algo(CRCW)" . $

=== Risorse di calcolo

Essendo i singoli processori delle RAM, abbiamo ancora le risorse di tempo $t(n)$ e spazio $s(n)$, ma dobbiamo aggiungere:
- $p(n)$ numero di processori richiesti su input di lunghezza $n$ nel caso peggiore;
- $T(n, p(n))$ tempo richiesto su input di lunghezza $n$ e $p(n)$ processori nel caso peggiore.

Notiamo come $T(n,1)$ rappresenta il *tempo sequenziale* $t(n)$.

Ogni processore $P_i$ esegue una serie di istruzioni nel passo parallelo, che possono essere più o meno in base al processore e al numero $p(n)$ di processori. Indichiamo con $ t_i^((j)) (n) $ il tempo che impiega il processore $j$-esimo per eseguire l'$i$-esimo passo parallelo su un input di lunghezza $n$. Quello che vogliamo ricavare è il *tempo complessivo* del passo parallelo: visto che dobbiamo aspettare che ogni processore finisca il proprio passo, calcoliamo il tempo di esecuzione $t_i (n)$ dell'$i$-esimo passo parallelo come $ t_i (n) = max {t_i^((j)) (n) bar.v 1 lt.eq j lt.eq p(n)} . $

Banalmente, il tempo complessivo di esecuzione del programma è la somma di tutti i tempi dei passi paralleli, quindi $ T(n, p(n)) = sum_(i=1)^(k(n)) t_i (n) . $

Notiamo subito come:
- $T$ dipende da $k(n)$, numero di passi paralleli;
- $T$ dipende $n$, dimensione dell'input;
- $T$ dipende da $p(n)$, numero di processori, perché diminuire/aumentare i processori causa un aumento/diminuzione dei tempi dei passi paralleli.

Confrontando $T(n, p(n))$ con $T(n,1)$ abbiamo due casi:
- $T(n, p(n)) = Theta(T(n,1))$, caso che vogliamo evitare;
- $T(n, p(n)) = o(T(n,1))$, caso che vogliamo trovare.

Introduciamo lo *speed-up*, il primo parametro utilizzato per l'analisi di un algoritmo parallelo. Esso viene definito come la quantità $ S(n, p(n)) = frac(T(n,1), T(n, p(n))) . $

Ad esempio, $S = 4$ indica che l'algoritmo parallelo è $4$ volte più veloce dell'algoritmo sequenziale, ma questo ricade nel caso $T(n, p(n)) = Theta(T(n,1))$, poiché il fattore che definisce la complessità si semplifica. Vogliamo avere $S arrow.long infinity$, poiché è la situazione di $o$ piccolo che tanto desideriamo.

Questo primo parametro è ottimo ma non basta: stiamo considerando il numero di processori? *NO*, questo perché $p(n)$ non compare da nessuna parte, e quindi noi potremmo avere $S arrow.long infinity$ perché stiamo utilizzando un numero spropositato di processori.

#example()[
  Ad esempio, nel *problema di soddisfacibilità* (_SODD_) potremmo utilizzare $2^n$ processori, ognuno dei quali risolve un assegnamento. Con una serie di _OR_ paralleli andiamo a vedere se siamo riusciti ad ottenere un assegnamento valido di variabili, tutto questo in tempo $ T(n,p(n)) = log_2(2^n) = n . $
]

Introduciamo quindi la variabile di *efficienza*, definita come $ E(n, p(n)) = frac(S(n, p(n)), p(n)) = frac(T(n, 1)^*, T(n, p(n)) dot p(n)) , $ dove $T(n,1)^*$ indica il miglior tempo sequenziale ottenibile.

Per comodità, da qui in avanti chiameremo $E(n,p(n))$ semplicemente con $E$.

#theorem()[
  Vale $ 0 lt.eq E lt.eq 1 . $
]

#proof[
  La dimostrazione di $E gt.eq 0$ risulta banale visto che si ottiene come rapporto di tutte quantità positive o nulle.

  La dimostrazione di $E lt.eq 1$ richiede di sequenzializzare un algoritmo parallelo, ottenendo un tempo $hat(T)(n,1)$ che però _"fa peggio"_ del miglior algoritmo sequenziale $T(n,1)^*$, quindi $ T(n,1)^* lt.eq hat(T)(n,1) lt.eq p(n) dot t_1 (n) + dots + p(n) dot t_(k(n)) (n) . $

  La somma di destra rappresenta la sequenzializzazione dell'algoritmo parallelo, che richiede quindi un tempo uguale a $p(n)$ volte il tempo che prima veniva eseguito al massimo in un passo parallelo. Risolvendo il membro di destra otteniamo $ T(n,1)^* lt.eq sum_(i=1)^(k(n)) p(n) dot t_i (n) = p(n) sum_(i=1)^(k(n)) t_i (n) = p(n) dot T(n, p(n)) . $

  Se andiamo a dividere tutto per il membro di destra otteniamo $ T(n,1)^* lt.eq p(n) dot T(n, p(n)) arrow.long.double frac(T(n,1)^*, p(n) dot T(n, p(n))) lt.eq 1 arrow.long.double E lt.eq 1 . qedhere $
]

Se $E arrow.long 0$ abbiamo dei problemi, perché nonostante un ottimo speed-up stiamo tendendo a $0$, ovvero il numero di processori utilizzati è eccessivo. Devo quindi ridurre il numero di processori $p$ senza degradare il tempo, passando da $p$ a $p / k$.

L'algoritmo parallelo ora non ha più $p$ processori, ma avendone di meno, per garantire l'esecuzione di tutte le istruzioni, vado a raggruppare in gruppi di $k$ le istruzioni sulla stessa riga, così che ogni processore dei $p / k$ totali a disposizione esegua $k$ istruzioni.

Il tempo per eseguire un blocco di $k$ istruzioni ora diventa $k dot t_i (n)$ nel caso peggiore, mentre il tempo totale diventa $ T(n, p/k) lt.eq sum_(i=1)^(k(n)) k dot t_i (n) = k sum_(i=1)^(k(n)) t_i (n) = k dot T(n, p(n)) . $

Calcoliamo l'efficienza con questo nuovo numero di processori, per vedere se è migliorata: $ E(n, p/k) = frac(T(n,1)^*, p/k dot T(n, p/k)) gt.eq frac(T(n,1)^*, p/cancel(k) dot cancel(k) dot T(n, p(n))) = frac(T(n,1)^*, p(n) dot T(n, p(n))) = E(n,p(n)) . $

Notiamo quindi che diminuendo il numero di processori l'*efficienza aumenta*.

Possiamo dimostrare infine che la nuova efficienza è comunque limitata superiormente da $1$: $ E(n, p(n)) lt.eq E(n, p/k) lt.eq E(n, p/p) = E(n, 1) = 1 . $

Questa idea di ridurre il numero di processori è quella che viene definita come *principio di Wyllie*: se $E arrow.long 0$ quando $T(n, p(n)) = o(T(n,1))$ allora è $p(n)$ che sta crescendo troppo, e dobbiamo quindi ridurre il numero di processori che utilizziamo.
