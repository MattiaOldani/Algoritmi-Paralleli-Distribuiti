// Alias

#import "@preview/ouset:0.1.1": overset

// Lezione 01

#let send(x, y) = {
  let sendop = math.class(
    "unary",
    "send",
  )
  $sendop(#x,#y)$
}

// Lezione 02

#let FP = $"FP"$
#let NP = $"NP"$
#let NC = $"NC"$

// Lezione 03

#let istr(i) = $"istruzione"_(#i)$

// Lezione 04

#let over(base, simbolo) = $overset(#base, #simbolo)$
