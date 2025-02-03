// Titolo e indice

#import "template.typ": *

#show: project.with(title: "Algoritmi paralleli e distribuiti")

#pagebreak()


// Introduzione

#include "capitoli/00_introduzione.typ"
#pagebreak()


// Algoritmi paralleli

#parte("Algoritmi paralleli")
#pagebreak()

#include "capitoli/paralleli/01_architetture.typ"
#pagebreak()

#include "capitoli/paralleli/02_sommatoria.typ"
#pagebreak()

#include "capitoli/paralleli/04_applicazioni-sommatoria.typ"
#pagebreak()

#include "capitoli/paralleli/05_somme-prefisse.typ"
#pagebreak()

#include "capitoli/paralleli/06_valutazione-polinomi.typ"
#pagebreak()

#include "capitoli/paralleli/07_ricerca.typ"
#pagebreak()

#include "capitoli/paralleli/08_ordinamento.typ"
#pagebreak()

#include "capitoli/paralleli/09_navigazione.typ"
#pagebreak()


// Algoritmi paralleli e memoria distribuita

#parte("Algoritmi paralleli a memoria distribuita")
#pagebreak()

#include "capitoli/paralleli-distribuita/01_introduzione.typ"
#pagebreak()

#include "capitoli/paralleli-distribuita/02_max-ordinamento.typ"
#pagebreak()

#include "capitoli/paralleli-distribuita/03_array-lineari.typ"
#pagebreak()

#include "capitoli/paralleli-distribuita/04_mesh.typ"
#pagebreak()


// Algoritmi distribuiti

#parte("Algoritmi distribuiti")
#pagebreak()

#include "capitoli/distribuiti/01_introduzione.typ"
#pagebreak()

#include "capitoli/distribuiti/02_broadcast.typ"
#pagebreak()

#include "capitoli/distribuiti/03_traversal.typ"
#pagebreak()

#include "capitoli/distribuiti/04_spanning-tree.typ"
#pagebreak()

#include "capitoli/distribuiti/05_election.typ"
#pagebreak()

#include "capitoli/distribuiti/06_routing.typ"
#pagebreak()
