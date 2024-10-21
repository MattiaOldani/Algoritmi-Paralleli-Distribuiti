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


= Lezione 04

== Parametri in gioco

Confrontando $T(n, p(n))$ con $T(n,1)$ abbiamo due casi:
- $T(n, p(n)) = Theta(T(n,1))$, caso che vogliamo evitare;
- $T(n, p(n)) = o(T(n,1))$, caso che vogliamo trovare.

Introduciamo lo *speed-up*, il primo parametro utilizzato per l'analisi di un algoritmo parallelo: viene definito come $ S(n, p(n)) = frac(T(n,1), T(n, p(n))) . $

Se ad esempio $S = 4$ vuol dire che l'algoritmo parallelo è $4$ volte più veloce dell'algoritmo sequenziale, ma questo vuol dire che sono nel caso di $T(n, p(n)) = Theta(T(n,1))$, poiché il fattore che definisce la complessità si semplifica.

Vogliamo quindi avere $S arrow infinity$, poiché è la situazione di $o$ piccolo che tanto desideriamo. Questo primo parametro è ottimo ma non basta: stiamo considerando il numero di processori? *NO*, questo perché $p(n)$ non compare da nessuna parte, e quindi noi potremmo avere $S arrow infinity$ perché stiamo utilizzando un numero spropositato di processori.

Ad esempio, nel problema di soddisfacibilità `SODD` potremmo utilizzare $2^n$ processori, ognuno dei quali risolve un assegnamento, poi con vari passi paralleli andiamo ad eseguire degli _OR_ per vedere se siamo riusciti ad ottenere un assegnamento valido di variabili, tutto questo in tempo $log_2 2^n = n$. Questo ci manda lo speed-up ad un valore che a noi piace, ma abbiamo utilizzato troppi processori.

Introduciamo quindi la variabile di *efficienza*, definita come $ E(n, p(n)) = frac(S(n, p(n)), p(n)) = frac(T(n, 1)^*, T(n, p(n)) dot p(n)) , $ dove $T(n,1)^*$ indica il miglior tempo sequenziale ottenibile.

#theorem()[
  $ 0 lt.eq E lt.eq 1 . $
]

#proof[
  La dimostrazione di $E gt.eq 0$ risulta banale visto che si ottiene come rapporto di tutte quantità positive o nulle.

  La dimostrazione di $E lt.eq 1$ richiede di sequenzializzare un algoritmo parallelo, ottenendo un tempo $over(T,tilde)(n,1)$ che però "fa peggio" del miglior algoritmo sequenziale $T(n,1)$, quindi $ T(n,1) lt.eq over(T, tilde)(n,1) lt.eq p(n) dot t_1 (n) + dots + p(n) t_(k(n)) (n) . $

  La somma di destra rappresenta la sequenzializzazione dell'algoritmo parallelo, che richiede quindi un tempo uguale $p(n)$ volte il tempo che prima veniva eseguito al massimo in un passo parallelo.

  Risolvendo il membro di destra otteniamo $ T(n,1) lt.eq sum_(i=1)^(k(n)) p(n) dot t_i (n) = p(n) sum_(i=1)^(k(n)) t_i (n) = p(n) dot T(n, p(n)) . $ Se andiamo a dividere tutto per il membro di destra otteniamo quello che vogliamo dimostrare, ovvero $ T(n,1) lt.eq p(n) dot T(n, p(n)) arrow.double frac(T(n,1), p(n) dot T(n, p(n))) lt.eq 1 arrow.double E lt.eq 1 . $
]

Se $E arrow 0$ abbiamo dei problemi, perché nonostante un ottimo speed-up stiamo tendendo a $0$, ovvero il numero di processori è eccessivo. Devo quindi ridurre il numero di processori $p(n)$ senza degradare il tempo, passando da $p$ a $p / k$.

L'algoritmo parallelo ora non ha più $p$ processori, ma avendone di meno per garantire l'esecuzione di tutte le istruzioni vado a raggruppare in gruppi di $k$ le istruzioni sulla stessa riga, così che ogni processore dei $p / k$ a disposizione esegua $k$ istruzioni.

Il tempo per eseguire un blocco di $k$ istruzioni ora diventa $k dot t_i (n)$ nel caso peggiore, mentre il tempo totale diventa $ T(n, p/k) lt.eq sum_(i=1)^(k(n)) k dot t_i (n) = k sum_(i=1)^(k(n)) t_i (n) = k dot T(n, p(n)) . $
