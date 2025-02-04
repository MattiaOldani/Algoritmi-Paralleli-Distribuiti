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

#let pad(x) = {
  let padop = math.class(
    "unary",
    "pad",
  )
  $padop(#x)$
}

#let sin(x) = {
  let sinop = math.class(
    "unary",
    "sin",
  )
  $sinop(#x)$
}

#let des(x) = {
  let desop = math.class(
    "unary",
    "des",
  )
  $desop(#x)$
}
