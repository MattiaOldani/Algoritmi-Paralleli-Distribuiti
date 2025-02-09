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

#let valore(x) = {
  let valoreop = math.class(
    "unary",
    "valore",
  )
  $valoreop(#x)$
}

#let rstato(x) = {
  let rstatoop = math.class(
    "unary",
    "stato",
  )
  $rstatoop(#x)$
}

#let rstatot(x, tempo) = {
  let rstatotop = math.class(
    "unary",
    "stato",
  )
  $rstatotop_(#tempo)(#x)$
}

#let ruolo(x) = {
  let ruoloop = math.class(
    "unary",
    "ruolo",
  )
  $ruoloop(#x)$
}

#let stato = $"STATO"$
#let evento = $"EVENTO"$
#let azione = $"AZIONE"$

#let nin(x) = {
  let ninop = math.class(
    "unary",
    $N_"in"$,
  )
  $ninop(#x)$
}

#let nout(x) = {
  let nouop = math.class(
    "unary",
    $N_"out"$,
  )
  $nouop(#x)$
}

#let pinit = $P_"init"$
#let pfinal = $P_"final"$

#let futuro(x) = {
  let futuroop = math.class(
    "unary",
    "futuro",
  )
  $futuroop(#x)$
}

#let sinit = $S_"init"$
#let sterm = $S_"term"$

#let send(x) = {
  let sendop = math.class(
    "unary",
    "send",
  )
  $sendop(#x)$
}

#let sstart = $S_"start"$
#let sfinal = $S_"final"$

#let sender = $"sender"$
#let next = $"next"$
