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


= Lezione 05

Iniziamo ad avere dei problemi quando $E arrow 0$: infatti, secondo il *principio di Wyllie*, se $E arrow 0$ quando $T(n, p(n)) = o(T(n,1))$ allora è $p(n)$ che sta crescendo troppo. In poche parole, abbiamo uno speed-up ottimo ma abbiamo un'efficienza che va a zero per via del numero di processori.

Riprendiamo dalla scorsa lezione.

Calcoliamo l'efficienza con questo nuovo numero di processori, per vedere se è migliorata: $ E(n, p/k) = frac(T(n,1), p/k dot T(n, p/k)) gt.eq frac(T(n,1), p/cancel(k) dot cancel(k) dot T(n, p(n))) = frac(T(n,1), p(n) dot T(n, p(n))) = E(n,p(n)) . $

Notiamo quindi che diminuendo il numero di processori l'efficienza aumenta.

Possiamo dimostrare infine che la nuova efficienza è comunque limitata superiormente da $1$ $ E(n, p(n)) lt.eq E(n, p/k) lt.eq E(n, p/p) = E(n, 1) = 1 . $

Dobbiamo comunque garantire la condizione di un buon speed-up, quindi $T(n, p/k) = o(T(n,1))$

== Sommatoria

Cerchiamo un algoritmo parallelo per il calcolo di una *sommatoria*.

Il programma prende in input una serie di numeri $M[1], dots, M[n]$ inseriti nella memoria della PRAM e fornisce l'output in $M[n]$. In poche parole, a fine programma si avrà $ M[n] = sum_(i=1)^n M[i] . $

Un buon algoritmo sequenziale è quello che utilizza $M[n]$ come accumulatore, lavorando in tempo $T(n,1) = n-1$ senza usare memoria aggiuntiva.

#align(center)[
  #pseudocode-list(title: [Sommatoria sequenziale])[
    - *input*:
      - vettore $M[]$ di grandezza $n$
    + for $i = 1$ to $n$ do:
      + $M[n] = M[n] + M[i]$
    + return $M[n]$
  ]
]

Un primo approccio parallelo potrebbe essere quello di far eseguire ad ogni processore una somma.

#v(12pt)

#figure(
  image("assets/05_sommatoria-naive.svg", width: 50%),
)

#v(12pt)

Usiamo $n-1$ processori, ma abbiamo dei problemi:
- l'albero che otteniamo ha altezza $n-1$;
- ogni processore deve aspettare la somma del processore precedente, quindi $T(n, n-1) = n-1$.

L'efficienza che otteniamo è $ E(n, n-1) = frac(n-1, (n-1) dot (n-1)) arrow 0 . $

Una soluzione migliore considera la _proprietà associativa_ della somma per effettuare delle somme $2$ a $2$.

#v(12pt)

#figure(
  image("assets/05_sommatoria-migliore-01.svg", width: 70%),
)

#v(12pt)

Quello che otteniamo è un albero binario, sempre con $n-1$ processori ma l'altezza dell'albero logaritmica in $n$. Il risultato di ogni somma viene scritto nella cella di indice maggiore, quindi vediamo la rappresentazione corretta.

#v(12pt)

#figure(
  image("assets/05_sommatoria-migliore-02.svg", width: 70%),
)

#v(12pt)

Quello che possiamo fare è sommare, ad ogni passo $i$, gli elementi che sono a distanza $i$: partiamo sommando elementi adiacenti a distanza $1$, poi $2$, fino a sommare al passo $log(n)$ gli ultimi due elementi a distanza $n/2$.

#align(center)[
  #pseudocode-list(title: [Sommatoria parallela])[
    + for $i = 1$ to $log(n)$ do:
      + for $k = 1$ to $frac(n,2^i)$ par do:
        + $M[2^i k] = M[2^i k] + M[2^i k - 2^(i-1)]$
    + return $M[n]$
  ]
]

Nell'algoritmo $k$ indica il numero di processori attivi nel passo parallelo.

=== EREW

#theorem()[
  L'algoritmo di sommatoria parallela è EREW.
]

#proof[
  Dobbiamo mostrare che al passo parallelo $i$ il processore $a$, che utilizza $2^i a$ e $2^i a - 2^(i-1)$, legge e scrive celle di memoria diverse rispetto a quelle usate dal processore $b$, che utilizza $2^i b$ e $2^i b - 2^(i-1)$.

  Mostriamo che $2^i a eq.not 2^i b$: questo è banale se $a eq.not b$.

  Mostriamo infine che $2^i a eq.not 2^i b - 2^(i-1)$: supponiamo per assurdo che siano uguali, allora $2 dot frac(2^i a, 2^i) = 2 dot frac(2^i b - 2^(i-1), 2^i) arrow.long.double 2a = 2b -1 arrow.long.double a = frac(2b - 1, 2)$ ma questo è assurdo perché $a in NN$.
]

=== Correttezza

#theorem()[
  L'algoritmo di sommatoria parallela è corretto.
]

#proof[
  Per dimostrare che è corretto mostriamo che al passo parallelo $i$ nella cella $2^i k$ ho i $2^i - 1$ valori precedenti, sommati a $M[2^i k]$, ovvero che $M[2^i k] = M[2^i k] + dots + M[2^i (k-1) + 1]$.

  Notiamo che se $i = log(n)$ allora ho un solo processore $k=1$ e ottengo la definizione di sommatoria, ovvero $M[n] = M[n] + dots + M[1]$.

  Dimostriamo per induzione.

  Passo base: se $i = 1$ allora $M[2k] = M[2k] + M[2k-1]$.
]

Continuiamo la prossima volta.
