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

= Ricerca

Questo problema:
- prende in *input* una serie di valori $M[1], dots, M[n]$ e un valore $alpha$;
- restituisce in *output* $1$ se $alpha in M$, $0$ altrimenti, mettendo il risultato della valutazione in $M[n]$.

Il migliore algoritmo sequenziale ha tempo $T(n,1) = n$ se consideriamo un array generico. Nel caso di array ordinato, tramite *ricerca dicotomica*, abbassiamo il tempo ad un fattore logaritmico. Considerando invece un algoritmo quantistico su un array non ordinato, il tempo vale $T(n,1) = sqrt(n)$, ma questo è dato dall'uso dell'*interferenza quantistica*.

Vediamo un prima versione CRCW parallela che utilizza una flag $F$.

#align(center)[
  #pseudocode-list(title: [*CRCW con flag*])[
    + $F = 0$
    + for $k=1$ to $n$ par do
      + if $M[k] == alpha$
        + F = 1
    + $M[n] = F$
  ]
]

L'uso della flag è necessario: senza flag, se a fine algoritmo vale $M[n] == 1$ avrei due casi:
- ho avuto esito positivo della ricerca;
- il valore $1$ era il valore originale che avevo in memoria.

Con questa versione ho quindi CR in $alpha$ e CW in $F$. Vengono utilizzati $p(n) = n$ processori con tempo costante. L'efficienza vale $ E = frac(n, n C) = 1/C eq.not 0 . $

Vediamo una seconda versione del problema, utilizzando un CREW (_quindi senza l'uso di flag_).

#align(center)[
  #pseudocode-list(title: [*CREW con MAX-iterato*])[
    + for $k=1$ to $n$ par do
      + $M[k] = (M[k] == alpha space ? space 1 : 0)$
    + MAX-iterato($M$)
  ]
]

Trasformiamo $M$ in un vettore booleano e poi vediamo il massimo valore presente in esso. Come prima, abbiamo la CR per l'accesso al valore $alpha$.

Stiamo utilizzando $p(n) = n$ processori, sempre con tempo costante. Con il *principio di Wyllie* andiamo a ridurre i processori a $p(n) = n/log(n)$ e il tempo a $T(n,p(n)) = log(n)$, che sono uguali a quelli del MAX-iterato. L'efficienza è quindi $ E = frac(n, frac(n, log(n)) log(n)) = C eq.not 0 . $

La terza versione del problema usa invece una politica EREW, che a noi piace molto.

#align(center)[
  #pseudocode-list(title: [*EREW con replica e MAX-iterato*])[
    + Replica($A$, $alpha$)
    + for $k=1$ to $n$ par do
      + $M[k] = (M[k] == A[k] space ? space 1 : 0)$
    + MAX-iterato($M$)
  ]
]

Usando sempre il *principio di Wyllie*, ogni modulo di questo algoritmo usa $p(n) = n/log(n)$ processori con tempo $T(n,p(n)) = log(n)$. L'efficienza vale quindi $ E = frac(n, frac(n, log(n)) log(n)) = C eq.not 0 . $

Il problema di ricerca ha alcune *varianti*:
- numero di volte in cui $alpha$ compare dentro $M$, risolto usando il modulo sommatoria al posto del modulo MAX-iterato, così da contare effettivamente quante volte $alpha$ è presente;
- indice massimo di $alpha$ dentro $M$, risolto assegnando $M[k] = k$ quando cerchiamo $alpha$ dentro $M$, mantenendo poi il MAX-iterato alla fine;
- posizione minima di $alpha$ dentro $M$, risolto usando una *OP iterata* tale che $ "OP"(x,y) = cases(min(x,y) & "se" x eq.not 0 and y eq.not 0, max(x,y) quad & "altrimenti") . $
