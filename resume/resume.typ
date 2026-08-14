// Pandoc typst template for the resume PDF.
// Used as: pandoc index.md --pdf-engine=typst --template=resume.typ --lua-filter=resume.lua

#let accent = rgb("#1a5f7a")
#let muted = rgb("#5b6570")
#let ink = rgb("#1a1a1a")
#let sans = ("Helvetica Neue", "Helvetica", "Arial")
#let serif = ("Charter", "Georgia", "Times New Roman")

#set document(title: [$title$], author: "Eric Warmenhoven")

#set page(
  paper: "us-letter",
  margin: (x: 0.72in, top: 0.62in, bottom: 0.55in),
  footer: context {
    if counter(page).final().first() > 1 {
      set align(center)
      text(font: sans, size: 7.5pt, fill: muted, tracking: 0.04em)[
        #state("docname").final()
        #h(0.5em) · #h(0.5em)
        #counter(page).display() / #counter(page).final().first()
      ]
    }
  },
)

#set text(font: serif, size: 10pt, fill: ink, lang: "en", hyphenate: false)
#set par(justify: false, leading: 0.58em, spacing: 0.72em)

#show link: it => text(fill: accent, it)

// Charter sets "++" very loose; tighten it up.
#show "C++": text(tracking: -0.1em)[C++]

#set list(marker: text(fill: accent)[•], indent: 0.15em, body-indent: 0.5em, spacing: 0.38em)
#show list: set par(leading: 0.5em)
#show list: set text(size: 9.6pt)

// Name and contact line (emitted by resume.lua)
#let name(body) = {
  state("docname").update(body)
  block(above: 0pt, below: 0.6em)[
    #set align(center)
    #text(font: sans, size: 21pt, weight: 300, tracking: 0.16em, fill: ink)[#upper(body)]
  ]
}

#let contactline(body) = block(below: 0.9em)[
  #set align(center)
  #text(font: sans, size: 9pt, fill: muted, tracking: 0.02em)[#body]
  #v(0.55em)
  #line(length: 100%, stroke: 0.9pt + accent)
]

// Section headings
#show heading.where(level: 2): it => block(above: 1.15em, below: 0.62em, sticky: true)[
  #text(font: sans, size: 8.5pt, weight: 600, tracking: 0.18em, fill: accent)[#upper(it.body)]
  #v(-0.62em)
  #line(length: 100%, stroke: 0.5pt + accent.lighten(60%))
]

#show heading: set block(sticky: true)

// Job / role entry: title left, dates right, org line underneath
#let job(title, org, dates) = block(above: 0.95em, below: 0.42em, sticky: true, width: 100%)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: (left + bottom, right + bottom),
    text(size: 10.5pt, weight: "bold")[#title],
    text(font: sans, size: 8.8pt, fill: muted)[#dates],
  )
  #v(-0.5em)
  #text(size: 9.6pt, fill: muted, style: "italic")[#org]
]

// "Languages: C, C++, ..." rows, aligned in a single grid
#let skills(..rows) = block(above: 0.35em, below: 0.35em, width: 100%)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 1.1em,
    row-gutter: 0.55em,
    ..rows.pos().map(row => (
      pad(top: 0.11em, text(font: sans, size: 8.4pt, weight: 600, fill: muted, tracking: 0.05em)[#upper(row.at(0))]),
      text(size: 9.6pt)[#row.at(1)],
    )).flatten()
  )
]

#let horizontalrule = v(0.2em)

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

$for(header-includes)$
$header-includes$

$endfor$
$body$
