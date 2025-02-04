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

= Max e ordinamento

Due problemi che vedremo nelle prossime architetture sono *max* e *ordinamento*.

Il problema *Max* si risolve facendo comunicare ogni coppia di processori, così che ogni processore possa calcolare nella sua memoria il valore massimo della sequenza.

#lemma()[
  Il tempo richiesto per Max in $G$ è almeno $delta$.
]

#proof()[
  Ogni coppia di processori deve comunicare, quindi anche i due processori a distanza massima, ma la distanza massima è il diametro $delta$.
]

Il problema *Ordinamento* si risolve trasferendo valori tra i processori per avere un ordinamento crescente. Vediamo un bound anche per questo problema.

#lemma()[
  Il tempo richiesto per Ordinamento in $G$ è almeno $ n/(2 beta) . $
]

#proof()[
  Dividiamo il grafo in due metà:
  - in $n/2$ nodi ho i numeri più alti;
  - in $n/2$ nodi ho i numeri più bassi.

  Il caso peggiore che possiamo avere è una sequenza ordinata in modo decrescente. Devo quindi scambiare tutte le posizioni delle due zone.

  Posso trasferire da una zona all'altra usando i $beta$ ponti che definiscono la ampiezza di bisezione. Dovendo trasferire $n/2$ valori usando $beta$ ponti, il numero di iterazioni è $ frac(n, 2 beta) . qedhere $
]

Per analizzare questi problemi abbiamo bisogno di una serie di oggetti molto carini, i *confrontatori* (_comparatori_), e anche delle loro primitive. Questi oggetti sono dei *ponti* che collegano due fili; una volta che il confrontatore prende in input i valori dei due fili, in quello sopra mette il *valore minimo* e in quello sotto mette il *valore massimo*.

Ci sono alcuni confrontatori che invertono l'ordine dei due fili. Come possiamo distinguere le due tipologie? Se il confrontare lavora come piace a noi allora il cerchio utilizzato è pieno, altrimenti il cerchio utilizzato è vuoto.

#v(12pt)

#figure(image("assets/02_confrontatori.svg", width: 70%))

#v(12pt)

Con i confrontatori possiamo create delle *reti di confrontatori*, ovvero delle reti che spostano sopra e sotto i valori inseriti nei fili. Una *sorting network* è una rete di confrontatori capace di ordinare una sequenza di valori contenuta nei fili.

Qua sotto vediamo un esempio di sorting network per input di grandezza $n = 3$.

#v(12pt)

#figure(image("assets/02_esempio-rete-3.svg", width: 70%))

#v(12pt)

Mentre qua sotto vediamo un esempio di sorting network per input di grandezza $n = 4$.

#v(12pt)

#figure(image("assets/02_esempio-rete-4.svg", width: 70%))

#v(12pt)

L'idea per un algoritmo parallelo è quella di raggruppare, in un passo, i confrontatori che agiscono su fili diversi, così da evitare accessi concorrenti allo stesso dato e controlli complicati.

Una *rete di confrontatori* la indichiamo con $ R(x_1, dots, x_n) = (y_1, dots, y_n) . $

La rete $R$ è una *sorting network* se e solo se $ forall (x_1, dots, x_n) in NN^n quad R(x_1, dots, x_n) = (y_1, dots, y_n) $ con $ y_1 < dots < y_n . $

Queste reti sono anche dette *reti di ordinamento test/swap oblivious*. Quest'ultimo aggettivo deriva dal fatto che i confronti non dipendono dall'input dato, ma sono fissati a priori.

Per sapere se una rete di confrontatori $R$ è una sorting network possiamo utilizzare il *principio 01*, ideato da *Donald Knuth* (_mio fratello_) nel $1972$.

#theorem([Principio 01])[
  Vale $ forall x in {0,1}^n space R "ordina" x arrow.long forall y in NN^n space R "ordina" y . $
]

In poche parole, se riesco ad ordinare ogni possibile vettore booleano allora riesco ad ordinare ogni possibile vettore intero. Questo è comodo perché i vettori booleani sono molto meno di quelli interi.

Molto comoda anche l'implicazione inversa, ovvero $ exists y in NN^n bar.v R "non ordina" y arrow.long.double exists x in {0,1}^n bar.v R "non ordina" x . $

Una cosa molto comoda dei confrontatori è inoltre la *linearità* rispetto ad una funzione $f$. Spieghiamo meglio: sia $f$ una *funzione monotona crescente*. Allora $ R(f(x_1), dots, f(x_n)) = f(R(x_1, dots, x_n)) = (f(y_1), dots, f(y_n)) . $

Questo strumento è detto *f-shift* su $R$. Cosa abbiamo mostrato? Abbiamo fatto vedere che:
- applicare $R$ ad $x$ e poi applicare $f$ OPPURE
- applicare $f$ ad $x$ e poi applicare $R$
mi genera lo stesso risultato.

#theorem()[
  Se $R$ è una rete non corretta allora $ exists x in NN^n bar.v R "non ordina" x . $

  In poche parole, esistono due indici $t,s$ tali che $ y_t > y_s and t < s . $
]

#proof()[
  Definiamo la funzione $g : NN arrow.long {0,1}$ tale che $ g(x) = cases(1 & "se" x gt.eq y_t, 0 quad & "altrimenti") . $

  Questa funzione è monotona crescente: vale $0$ fino a $y_t$ (_escluso_) poi vale $1$ dai valori successivi.

  Vado ad applicare $g$ alla rete $R$ ottenendo $ R(g(x_1), dots, g(x_n)) . $

  Per la regola dello shift questa quantità è $ (g(y_1), dots, g(y_n)) . $

  Questo vettore binario non è ordinato perché $g(y_t) = 1$ mentre $g(y_s) = 0$. Ma allora la rete $R$ non ha ordinato la nostra sequenza.
]
