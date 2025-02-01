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

= Applicazioni di sommatoria

== Prodotto interno di vettori

Per questo problema abbiamo:
- input $x,y in NN^n$;
- output $<x,y> = sum_(i=1)^n x_i dot y_i$.

Il tempo sequenziale è $2n-1$, formato da $n$ prodotti e $n-1$ somme finali.

Sommatoria viene usata qua come modulo:
- *prima fase*: eseguo $log(n)$ prodotti in sequenza delle componenti e la somma dei valori del blocco in sequenza;
- *seconda fase*: somma di $p = n/log(n)$ prodotti.

Per sommatoria ho:
- $p = c_1 n/log(n)$;
- $t = c_2 log(n)$.

Per la prima fase:
- $p = n/log(n)$ quindi $Delta = n/p = log(n)$;
- $t = c_3 log(n)$.

Ma allora ho $p = n/log(n)$ e $t = log(n)$.

L'efficienza è $ E = frac(2n-1, n/log(n) dot log(n)) arrow.long K eq.not 0 . $

== Prodotto matrice vettore

Il prodotto interno di vettori ora viene usato come modulo per questo problema.

Questo problema è definito da:
- *input*: $A in NN^(n times n)$ e $x in NN^n$;
- *output*: $A dot x$.

Il tempo sequenziale è $n(2n-1) = 2n^2 - n$.

Idea: uso il modulo $angle.l dots,dots angle.r$ in parallelo $n$ volte. Il vettore se è acceduto simultaneamente dai moduli precedenti ci obbliga ad avere una politica CREW.

Che prestazioni abbiamo? Abbiamo:
- $p(n) = n n/log(n)$;
- $T(n,p(n)) = log(n)$.

L'efficienza vale $ E(n,T(n,p(n))) = frac(n^2, n^2/log(n) log(n)) arrow.long K eq.not 0 . $

== Prodotto matrice matrice

Uso ancora il prodotto interno come modulo.

Questo problema è definito da:
- *input*: $A,B in NN^(n times n)$;
- *output*: $A dot B$.

Il miglior tempo sequenziale è $n^(2.8)$ per *Strassen*.

Faccio $n^2$ prodotto interni in parallelo, anche qui politica CREW perché ogni riga di $A$ e ogni colonna di $B$ vengono accedute simultaneamente.

Prestazioni:
- $p(n) = n^2 n/log(n)$;
- $T(n,p(n)) = log(n)$.

L'efficienza vale $ E(n,T(n,p(n))) = frac(n^(2.80), n^3/log(n) log(n)) arrow 0 . $ Tende a $0$ ma lentamente, lo accettiamo.

== Potenza di matrice

L'ultimo problema di questo capitolo è definito da:
- *input*: $A in NN^(n times n)$;
- *output*: $A^t$, con $t = 2k$.

Prodotto iterato della stessa matrice, l'algoritmo sequenziale è:

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

L'efficienza è $ E = frac(n^(2.8) log(n), n^3 / log(n) dot log^2 (n)) = frac(n^2.8, n^3) arrow.long 0 . $ Sempre lentamente.
