// Setup

#import "@preview/ouset:0.2.0": *


// Alias

#let send(x, y) = {
  let sendop = math.class(
    "unary",
    "send",
  )
  $sendop(#x,#y)$
}

#let FP = $italic("FP")$
#let NP = $italic("NP")$
#let NC = $italic("NC")$

#let istr(i) = $"istruzione"_(#i)$

#let over(base, simbolo) = overset(base, simbolo)
