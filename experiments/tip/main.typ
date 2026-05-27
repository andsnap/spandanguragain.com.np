#let data = json("data.json")

// Bold helper — only renders value if non-empty
#let f(val) = {
  if val != "" and val != none { [*#val*] }
}

#set underline(stroke: 0.5pt + black)
#set text(font: ("Times New Roman", "Noto Serif Devanagari"), size: 10pt)
#set page(paper: "a4", margin: (x: 0.5in, y: 0.5in))
#set par(leading: 8pt, spacing: 8pt)

// ── Title ──────────────────────────────────────────────────────────────────
#align(center)[
  #set text(size: 13pt, weight: "bold")
  #underline[शिक्षण सुधार योजना (TIP)]
]

#v(8pt)

// ── Header Info ────────────────────────────────────────────────────────────
#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [शिक्षकको नाम : #f(data.at("teacher_name", default: ""))],
  align(right)[योजना अवधि : #f(data.at("period", default: ""))],
)
विद्यालय : #f(data.at("school_name", default: ""))

#v(6pt)

// ── Main Indicator Table ───────────────────────────────────────────────────
#table(
  columns: (24pt, 115pt, 80pt, 48pt, 48pt, 1fr),
  align: (col, row) => {
    if row <= 0 { center + horizon }
    else if col == 0 or col == 3 or col == 4 { center + horizon }
    else { left + horizon }
  },
  stroke: 0.5pt,

  // Header
  table.header(
    [*क्रम*],
    [*सूचक*],
    [*कक्षा\ विषय*],
    [*मौजुदा\ स्थिति*],
    [*अपेक्षित\ लक्ष्य*],
    [*लक्ष्य पूरा गर्न सम्पादन गरिने मुख्य कार्यहरू*],
  ),

  // ── Row 1: Student achievement (Dynamic subjects) ─────────────────────
  ..{
    let subs = data.at("subjects", default: ())
    if subs.len() == 0 {
      subs = ( (class: "", subject: "", current: "", expected: ""), )
    }
    let num_subjects = subs.len()
    let cells = ()
    for (i, sub) in subs.enumerate() {
      if i == 0 {
        cells.push(table.cell(rowspan: num_subjects, align: center + horizon)[१.])
        cells.push(table.cell(rowspan: num_subjects)[विद्यार्थीको औसत उपलब्धी])
      }
      cells.push([कक्षा: #f(sub.at("class", default: "")) \ विषय: #f(sub.at("subject", default: ""))])
      cells.push([#f(sub.at("current", default: ""))])
      cells.push([#f(sub.at("expected", default: ""))])
      if i == 0 {
        cells.push(table.cell(rowspan: num_subjects, align: left + top)[
          #set par(leading: 7pt, spacing: 6pt)
          #set text(size: 9pt)
          #(data.at("row1_actions", default: ""))
        ])
      }
    }
    cells
  },

  // ── Row 2 ──────────────────────────────────────────────────────────────
  [२.],
  table.cell(colspan: 2)[स्वमूल्याङ्कनका आधारमा शिक्षणमा शैक्षिक सामग्री प्रयोगका स्थिति (न्यूनबाट उच्च तहको दरमा १,२,३,४ मा मापन गर्ने)],
  [#f(data.at("row2_current", default: ""))],
  [#f(data.at("row2_expected", default: ""))],
  align(left + top)[#set text(size: 9pt); #set par(leading: 7pt); #(data.at("row2_actions", default: ""))],

  // ── Row 3 ──────────────────────────────────────────────────────────────
  [३.],
  table.cell(colspan: 2)[स्वमूल्याङ्कनका आधारमा क्रियाकलाप सञ्चालनको स्थिति (न्यूनबाट उच्च तहको दरमा १,२,३,४ मा मापन गर्ने)],
  [#f(data.at("row3_current", default: ""))],
  [#f(data.at("row3_expected", default: ""))],
  align(left + top)[#set text(size: 9pt); #set par(leading: 7pt); #(data.at("row3_actions", default: ""))],

  // ── Row 4 ──────────────────────────────────────────────────────────────
  [४.],
  table.cell(colspan: 2)[प्रतिदिन क्रियाकलाप विवरण तयारी सहितको शिक्षण गरेको पाठ सङ्ख्या],
  [#f(data.at("row4_current", default: ""))],
  [#f(data.at("row4_expected", default: ""))],
  align(left + top)[#set text(size: 9pt); #set par(leading: 7pt); #(data.at("row4_actions", default: ""))],

  // ── Row 5 ──────────────────────────────────────────────────────────────
  [५.],
  table.cell(colspan: 2)[स्वमूल्याङ्कनका आधारमा प्रभावकारी शिक्षणका निमित्त विद्यालय प्र.अ.बाट प्राप्त सहयोगको स्थिति (न्यूनबाट उच्च तहको दरमा १,२,३,४ मा मापन गर्ने)],
  [#f(data.at("row5_current", default: ""))],
  [#f(data.at("row5_expected", default: ""))],
  align(left + top)[#set text(size: 9pt); #set par(leading: 7pt); #(data.at("row5_actions", default: ""))],

  // ── Row 6 ──────────────────────────────────────────────────────────────
  [६.],
  table.cell(colspan: 2)[प्र.अ. / प्रशिक्षकबाट / सहकर्मीबाट कक्षा अवलोकन संख्या],
  [#f(data.at("row6_current", default: ""))],
  [#f(data.at("row6_expected", default: ""))],
  align(left + top)[#set text(size: 9pt); #set par(leading: 7pt); #(data.at("row6_actions", default: ""))],
)

#v(70pt)

// ── Footer ─────────────────────────────────────────────────────────────────
  #grid(
    columns: (1fr, auto, auto, auto),
    column-gutter: 2cm,

    [मिति : #f(data.at("date", default: ""))],

    align(center)[
      #overline(offset: -15pt)[विद्यालयको छाप]
    ],

    align(center)[
      #overline(offset: -15pt)[शिक्षकको दस्तखत]
    ],

    align(center)[
      #overline(offset: -15pt)[प्रमुखको दस्तखत]
    ],
  )
