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

= Max e ordinamento

Problemi che vedremo sulle architetture parallela a memoria distribuita:
- max: comunicazione a coppie di processori $delta$ basso comunicazione veloce
- ordinamento: spostamenti di parti dell'input $beta$ alto ordinamento efficiente

Valgono i seguenti limiti inferiori per i tempi di soluzione

#lemma()[
  Il tempo richiesto per MAX in G è almeno $delta$
]

#proof()[
  Ogni coppia di processori deve comunicazione, quindi servono almeno $delta$ passo parallelo
]

#lemma()[
  Il tempo richiesto per ORDINAMENTO in G è almeno $ n/2 1/beta $
]

#proof()[
  Divido il grafo in due metà:
  - in $n/2$ ho i numeri più alti
  - in $n/2$ ho i numeri più bassi

  Noi vogliamo crescente, nel caso peggiore sono tutto decrescente

  Quanti trasferimenti devo fare? Posso trasferire da una nuvola all'altra in beta, quindi facendo $n/2$ ci metto $n/2 1/beta$. Perché ho a disposizione $beta$ ponti.
]

Per analizzare questi problemi abbiamo bisogno dei confrontatori/comparatori e delle loro primitive.

Sono dei ponti che collegano due fili, sopra mettono il minimo e sotto il massimo dei due valori

if A[i] > A[j] then SWAP(A[i], A[j]) con i < j

Ci sono alcuni che fanno il contrario, quindi max sopra min sotto e il confronto ha il minore. Se minimo sopra cerchio, se minimo sotto cerchio vuoto.

Possiamo creare reti di confrontatori, ovvero metto un input per ogni filo e metto una serie di confrontatori. Una sorting network è una rete di confrontatori che ordina

Metti esempio per 3 e 4 elementi

Una rete generale di ordinamento è data dal bubble sort, ovvero ad ogni fase l'elemento più pesante viene spinto verso il basso.

Idea parallela: i confrontatori che agiscono su fili diversi vengono messi in un passo parallelo. In quello da 4 elementi ho $T(n) = \#"step"$ e $p(n) = 4$.

Una rete di confrontatori la indichiamo con $R(x_1, dots, x_n) = (y_1, dots, y_n)$

Si dice che $R$ è una sorting network se e solo se $ forall (x_1, dots, x_n) in NN^n quad R(x_1, dots, x_n) = (y_1, dots, y_n) $ con $ y_1 < dots < y_n $

Sono anche dette reti di ordinamento test/swap oblivious (confronti non dipendono dall'input ma sono fissati a priori)

Ci chiediamo se $R$ sia una sorting network. Per saperlo usiamo il principio $0-1$ (zero uno, knuth nel 1972)

Formalmente, $ forall x in {0,1}^n quad R(x) "ordinato" arrow.long forall y in NN^n quad R(y) "ordinato" $

Se vale un booleano vale anche per tutti gli altro

Vale anche esiste + non ordinato implica esiste + non ordinato

Introduciamo uno strumento: f-shift su $R$

Abbiamo una rete $R$ e una funzione $f$. Prima applico f e poi R, oppure prima R e poi f, ovvero $ R(f(x_1), dots, f(x_n)) = f(R(x_1, dots, x_n)) = (f(y_1), dots, f(y_n)) $

Per essere vero $f$ deve essere monotona crescente, perché i confrontatori trovano minimo e massimo e f non cambia niente

#theorem()[
  Se $R$ non corretta esiste $x in NN^n$ tale che $R(x)$ non ordina, quindi esistono $k,s$ tali che $y_k > y_s$ ma $k < s$
]

#proof()[
  Definiamo $g = NN arrow.long {0,1} = cases(1 "se" x gt.eq y_k, 0 "altrimenti")$

  Vediamo come sia monotona crescente

  Ora applico $f$ a $R$ e ottengo $ R(g(x_1), dots, g(x_n)) $ ma per la regola dello shift questa cosa è uguale a $ (g(y_1), dots, g(y_n)) $ vettore binario che non è ordinato perché $g(y_k)$ vale $1$ mentre in $g(y_s)$ vale 0 perché più piccolo.

  Ma allora non ho ordinato
]

Per testare una R e capire se è sorting network mi basta valutare $R$ solo su input binari, molto più facile da fare
