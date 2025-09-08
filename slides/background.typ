#set page(flipped: true, margin: 0pt)


#let loop = range(-3, 3).map(i => grid.cell(align: center + horizon, rotate(i * 20deg, image(
  "nix.svg",
  height: 2em + (calc.pow(i, 2) * 0.1em),
))))

#let row = grid(
  columns: (4em,) * 100, rows: (4em,), gutter: 0em,
  ..range(10).map(_ => loop).flatten()
)

#block(height: 100%)[
  #stack(..range(14).map(i => move(dx: -i * 2em, row)))
]
