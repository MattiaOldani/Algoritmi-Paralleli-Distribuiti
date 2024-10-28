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


= Lezione 07

== Ancora sommatoria

Diamo un *lower bound*: per sommatoria possiamo visualizzare usando un albero binario, con le foglie dati di input e i livelli sono i passi paralleli. Il livello con più nodi dà il numero di processori e l'altezza dell'albero il tempo dell'algoritmo.

Se abbiamo altezza $h$, abbiamo massimo $2^h$ foglie, quindi $ "foglie" = n lt.eq 2^h arrow.long.double h gt.eq log(n) $ quindi ho sempre tempo logaritmico.

La sommatoria può essere uno schema per altri problemi.

*Operazione iterata*: abbiamo op che è associativa, abbiamo:
- *input*: $M[1], dots, M[n]$ valori
- *output*: calcolare $"op"_i M[i] arrow M[n]$ ovvero calcolare op su una serie di valori e mettere nella cella finale.

Abbiamo soluzioni efficienti per questo:
- $p = O(n/log(n))$;
- $T = O(log(n))$.

Con modelli PRAM più potenti (non EREW) possiamo ottenere un tempo costante (per AND e OR).

== AND iterato

Supponiamo una CRCW-PRAM, vediamo il problema *and iterato*, ovvero $M[n] = and.big_i M[i]$.

Qui abbiamo tempo costante perché la PRAM è più potente.

L'algoritmo è il seguente.

#align(center)[
  #pseudocode-list(title: [$and.big$ iterato])[
    + for $1 lt.eq k lt.eq n$ par do
      + if $M[k] = 0$ then
        + $M[n] = 0$
  ]
]

Serve CW con politica common, quindi scrivono i processori sse il dato da scrivere è uguale per tutti, ma anche le altre vanno bene (random o priority).

Abbiamo:
- $p(n) = n$;
- $T(n,n) = 3$;
- $E(n,n) = (n-1)/(3n) arrow 1/3$.

Per $or.big$ iterato stessa cosa, basta che almeno uno sia $1$.

La sommatoria può essere usata anche come sotto-problema di altri, ad esempio:
- prodotto interno di vettori;
- prodotto matrice-vettore;
- prodotto matrice-matrice;
- potenza di una matrice.

== Prodotto interno di vettori

- input $x,y in NN^n$
- output $<x,y> = sum_(i=1)^n x_i dot y_i$

Il tempo sequenziale è $2n-1$, $n$ per le somme e $n-1$ somme finali.

Sommatoria viene usata qua come modulo:
- prima fase: eseguo $Delta = log(n)$ prodotti in sequenza delle componenti e la somma dei valori del blocco in sequenza;
- seconda fase: somma di $p = n/log(n)$ prodotti.

Per sommatoria ho:
- $p = c_1 n/log(n)$;
- $t = c_2 log(n)$.

Per la prima fase:
- $p = n/log(n)$ quindi $delta = n/p = log(n)$;
- $t = c_3 log(n)$.

Ma allora ho $p = n/log(n)$ e $t = log(n)$.

L'efficienza è $ E = frac(2n-1, n/log(n) dot log(n)) arrow C eq.not 0 . $

== Prodotto matrice vettore

Roba di prima è modulo per questo.

- input: $A in NN^(n times n)$ e $x in NN^n$
- output: $A dot x$

Il tempo sequenziale è $n(2n-1) = 2n^2 - n$.

Idea: uso il modulo $<dots,dots>$ in parallelo $n$ volte. Il vettore se è acceduto simultaneamente dai moduli $<>$ ci obbliga ad avere CREW.

Che prestazioni abbiamo? Abbiamo:
- $p(n) = n n/log(n)$;
- $T(n,p(n)) = log(n)$.

L'efficienza vale $ E(n,T(n,p(n))) = frac(n^2, n^2/log(n) log(n)) arrow C eq.not 0 . $

== Prodotto matrice matrice

Modulo uso sempre prodotto interno.

- input: $A,B in NN^(n times n)$;
- output: $A dot B$.

Il tempo sequenziale è $n^(2.8)$ per Strassen.

Uso $n^2$ prodotto interni in parallelo, anche qui CREW perché ogni riga di $A$ e ogni colonna di $B$ viene acceduta simultaneamente.

Prestazioni:
- $p(n) = n^2 n/log(n)$;
- $T(n,p(n)) = log(n)$.

L'efficienza vale $ E(n,T(n,p(n))) = frac(n^(2.80), n^3/log(n) log(n)) arrow 0 . $ Tende a $0$ ma lentamente.

== Potenza di matrice

- input: $A in NN^(n times n)$;
- output: $A^t$ con $t = 2k$.

Prodotto iterato della stessa matrice, sequenziale è:

#align(center)[
  #pseudocode-list(title: [Potenza di matrice sequenziale])[
    + for $i = 1$ to $log(n)$ do
      + $A = A dot A$
  ]
]

Saltiamo i calcoli intermedi, facciamo $A arrow A^2 arrow A^4 arrow A^8 arrow dots$.

Il tempo è quindi $n^(2.8) log(n)$.

L'approccio parallelo per $log(n)$ volte esegue il prodotto $A dot A$, anche questo CREW.

Abbiamo:
- $p(n) = n^3 / log(n)$;
- $T(n,p(n)) = log(n) dot log(n) = log^2 (n)$.

L'efficienza è $ E = frac(n^(2.8) log(n), n^3 / log(n) dot log^2 (n)) = frac(n^2.8, n^3) arrow 0 . $ Sempre lentamente.

== Somme prefisse

Contiene anche lui il problema della sommatoria.

- input: $M[1], dots, M[n]$;
- output: $sum_(i=1)^k M[i] arrow k quad 1 lt.eq k lt.eq n$.

Assumiamo $n$ potenza di $2$ per semplicità.

L'algoritmo sequenziale somma nella cella $i$ quello che c'è nella cella $i-1$.

#align(center)[
  #pseudocode-list(title: [Algoritmo sequenziale furbo])[
    + for $k = 2$ to $n$ do
      + $M[k] = M[k] + M[k-1]$
  ]
]

Il tempo di questo algoritmo è $n-1$.

Vediamo una proposta parallela. Al modulo sommatoria passo tutti i possibili prefissi: un modulo somma i primi due, un modulo i primi tre, eccetera.

Problemi:
- non è EREW ma questo chill;
- ho un CREW su PRAM con $p(n) lt.eq (n-1) n/log(n) = n^2 /log(n) = sum_(i=2)^n i/log(i) gt.eq 1/log(n) sum_(i=2)^n i approx n^2 / log(n)$ e $T(n,p(n)) = log(n)$.

Ma allora $ E = frac(n-1, n^2/log(n) log(n)) arrow 0 $ buuuuu poco efficiente.
