#let data = json("data.json")

#let to-nepali-num(num) = {
  let num-str = str(num)
  let nep-digits = ("0": "०", "1": "१", "2": "२", "3": "३", "4": "४", "5": "५", "6": "६", "7": "७", "8": "८", "9": "९")
  let result = ""
  for char in num-str.clusters() {
    result += nep-digits.at(char, default: char)
  }
  result
}

#let f(val) = {
  if val != "" and val != none {
    [*#val*]
  } else {
    []
  }
}

#let f_addr(val) = {
  if val != "" and val != none {
    [*#val*]
  } else {
    []
  }
}

#let cv(val) = {
  if val != "" and val != none {
    [#val]
  } else {
    []
  }
}

#let wrap-text(s) = {
  if s != none and type(s) == str {
    pad(right: 3pt)[#s.clusters().join(sym.zws)]
  } else {
    s
  }
}

#let render-rows(data-list, empty-rows-count, row-mapper) = {
  let rows = ()
  let count = 0
  if data-list != none and data-list.len() > 0 {
    for (i, item) in data-list.enumerate() {
      rows += row-mapper(i + 1, item)
      count += 1
    }
  }
  if count < empty-rows-count {
    for i in range(count + 1, empty-rows-count + 1) {
      rows += row-mapper(i, none)
    }
  }
  rows
}

#set underline(stroke: 0.5pt + black)
#set par(leading: 8pt, spacing: 8pt)
#set text(font: ("Times New Roman", "Noto Serif Devanagari"), size: 10pt)
#show math.equation: set text(font: ("Times New Roman", "Noto Serif Devanagari"))
#show heading.where(level: 2): set text(size: 13pt)
#show heading.where(level: 3): set text(size: 11pt)
#set page(
  paper: "a4", 
  flipped: true, 
  margin: (x: 0.75in, y: 0.75in),
  footer: context {
    let page-num = counter(page).get().first()
    align(center)[#to-nepali-num(page-num)]
  }
)

#align(center)[
  #set text(size: 8.5pt)
  सम्पत्ति विवरण पेश गर्ने प्रयोजनको लागि तोकिएको फारामको ढाँचा सम्बन्धमा नेपाल राजपत्र, भाग ५, खण्ड ६० संख्या १ मिति २०६७ बैशाख ६ गते प्रकाशित भै संशोधन भएको । \
]
#align(center)[
  #set text(size: 12pt)
  (भ्रष्टाचार निवारण ऐन, २०५९ को दफा ५० को उपदफा (१) तथा अख्तियार दुरुपयोग अनुसन्धान आयोग ऐन, २०४८ को दफा ३१ क. को उपदफा (१) को प्रयोजनको लागि)
]

#v(3pt)
#align(center)[
  #set text(size: 14pt, weight: "bold")
  #underline[सम्पत्ति विवरण फाराम]
]
#v(8pt)

सार्वजनिक पदधारण गरेको व्यक्तिको नाम, थर:- #f(data.at("nama", default: ""))

#v(4pt)
#grid(
  columns: (1.2fr, 1.5fr),
  row-gutter: 10pt,
  [
    पद :- #f(data.at("pad", default: "")) \
  ],
  [
    विवरण पेश गरेको निकाय :- #f(data.at("nikaya", default: "")) \
    #v(10pt)
    कार्यालय :- #f(data.at("karyalaya", default: "")) \
    #v(10pt)
    विवरण पेश गरेको आ.ब. :- #f(data.at("fiscal_year", default: ""))
  ]
)

#v(6pt)
*स्थायी ठेगाना :*
#grid(
  columns: (1fr, 1.2fr, 0.8fr, 1fr),
  [जिल्ला :- #f_addr(data.at("sthayi_jilla", default: ""))],
  [गा.वि.स. / न.पा. :- #f_addr(data.at("sthayi_vdc_mp", default: ""))],
  [वडा नं. :- #f_addr(data.at("sthayi_wada", default: ""))],
  [टोल :- #f_addr(data.at("sthayi_tol", default: ""))],
)

#v(6pt)
*हाल बसोबास गरेको ठेगाना :*
#grid(
  columns: (1fr, 1.2fr, 0.8fr, 1fr),
  [जिल्ला :- #f_addr(data.at("temporary_jilla", default: ""))],
  [गा.वि.स. / न.पा. :- #f_addr(data.at("temporary_vdc_mp", default: ""))],
  [वडा नं. :- #f_addr(data.at("temporary_wada", default: ""))],
  [टोल :- #f_addr(data.at("temporary_tol", default: ""))],
)

#v(10pt)
#grid(
  columns: (1fr, 1fr),
  [कर्मचारी भए संकेत नम्बर:- #f(data.at("sanket_no", default: ""))],
  [स्थायी लेखा नं.:- #f(data.at("pan", default: ""))]
)


#if data.at("break_ghar", default: false) [ #pagebreak() ] else [ #v(5pt) ]
== १. अचल सम्पत्तिको विवरण
*(क) घर*

#let ghar-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("owner_name", default: ""))],
      [#cv(item.at("jilla", default: ""))],
      [#cv(item.at("vdc_mp", default: ""))],
      [#cv(item.at("wada", default: ""))],
      [#cv(item.at("kitta", default: ""))],
      [#cv(item.at("area", default: ""))],
      [#cv(item.at("price", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 1.8fr, 1.2fr, 1.8fr, 30pt, 40pt, 50pt, 1.2fr, 1.5fr, 1.2fr),
  align: (col, row) => if col == 0 or (row < 2) { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    table.cell(rowspan: 2)[*क्र.स*],
    table.cell(rowspan: 2)[*घर धनीको नाम*],
    table.cell(colspan: 5)[*घर र घरले चर्चेको जग्गाको विवरण*],
    table.cell(rowspan: 2)[*खरीद गरेको\ भए खरीद मूल्य*],
    table.cell(rowspan: 2)[*प्राप्तिको स्रोत*],
    table.cell(rowspan: 2)[*कैफियत*],
    
    [*जिल्ला*], [*गा.वि.स. / न.पा.*], [*वडा नं.*], [*किल्ला नं.*], [*क्षेत्रफल (वर्ग मिटर)*]
  ),
  ..render-rows(data.at("table_ghar", default: ()), 1, ghar-mapper)
)

#if data.at("break_jagga", default: false) [ #pagebreak() ] else [ #v(5pt) ]
=== (ख) जग्गा :

#let jagga-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("owner_name", default: ""))],
      [#cv(item.at("jilla", default: ""))],
      [#cv(item.at("vdc_mp", default: ""))],
      [#cv(item.at("wada", default: ""))],
      [#cv(item.at("kitta", default: ""))],
      [#cv(item.at("area", default: ""))],
      [#cv(item.at("price", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 1.8fr, 1.2fr, 1.8fr, 30pt, 40pt, 50pt, 1.2fr, 1.5fr, 1.2fr),
  align: (col, row) => if col == 0 or (row < 2) { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    table.cell(rowspan: 2)[*क्र.स*],
    table.cell(rowspan: 2)[*जग्गा धनीको नाम*],
    table.cell(colspan: 5)[*जग्गाको विवरण*],
    table.cell(rowspan: 2)[*खरीद गरेको\ भए सोको मूल्य*],
    table.cell(rowspan: 2)[*प्राप्तिको स्रोत*],
    table.cell(rowspan: 2)[*कैफियत*],
    
    [*जिल्ला*], [*गा.वि.स. / न.पा.*], [*वडा नं.*], [*कित्ता नं.*], [*क्षेत्रफल*]
  ),
  ..render-rows(data.at("table_jagga", default: ()), 1, jagga-mapper)
)

#if data.at("break_nagad", default: false) [ #pagebreak() ] else [ #v(5pt) ]
== २. चल सम्पत्तिको विवरण
*(क) नगद, सुन, चाँदी, हिरा, जवाहरात :*

#let nagad-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("details", default: ""))],
      [#cv(item.at("quantity", default: ""))],
      [#cv(item.at("date", default: ""))],
      [#cv(item.at("price", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 3fr, 50pt, 70pt, 70pt, 1.5fr, 1fr),
  align: (col, row) => if col == 0 or row == 0 { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    [*क्र.सं.*], [*विवरण*], [*परिमाण*], [*प्राप्त मिति*], [*खरीद गरेको भए खरीद मूल्य*], [*प्राप्तिको स्रोत*], [*कैफियत*]
  ),
  ..render-rows(data.at("table_nagad", default: ()), 1, nagad-mapper)
)

#if data.at("break_bank", default: false) [ #pagebreak() ] else [ #v(5pt) ]
*(ख) बैंक, वित्तीय संस्था तथा सहकारी संस्थामा रहेको खाताको विवरण*

#let bank-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("account_holder", default: ""))],
      [#cv(item.at("bank_name_address", default: ""))],
      [#cv(wrap-text(item.at("account_no", default: "")))],
      [#cv(item.at("balance", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 2.2fr, 2.8fr, 2.8fr, 70pt, 1.5fr, 1fr),
  align: (col, row) => if col == 0 or row == 0 { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    [*क्र.सं.*], [*खातावालाको नाम*], [*संस्थाको नाम र ठेगाना*], [*खाता नं.*], [*मौज्दात रकम*], [*प्राप्तिको स्रोत*], [*कैफियत*]
  ),
  ..render-rows(data.at("table_bank", default: ()), 1, bank-mapper)
)

#if data.at("break_securities", default: false) [ #pagebreak() ] else [ #v(5pt) ]
*(ग) धितोपत्र, शेयर वा ऋणपत्रको विवरण*

#let securities-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("shareholder_name", default: ""))],
      [#cv(item.at("company_name_address", default: ""))],
      [#cv(item.at("type", default: ""))],
      [#cv(item.at("quantity", default: ""))],
      [#cv(item.at("amount", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 2fr, 2.5fr, 1.2fr, 45pt, 65pt, 1.5fr, 1fr),
  align: (col, row) => if col == 0 or (row < 2) { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    table.cell(rowspan: 2)[*क्र.स.*],
    table.cell(rowspan: 2)[*शेयरधनीको\ नाम, थर*],
    table.cell(rowspan: 2)[*कम्पनीको नाम, ठेगाना*],
    table.cell(rowspan: 2)[*शेयर/ऋणपत्रको\ किसिम*],
    table.cell(colspan: 2)[*शेयर/ऋणपत्रको विवरण*],
    table.cell(rowspan: 2)[*प्राप्तिको\ स्रोत*],
    table.cell(rowspan: 2)[*कैफियत*],
    
    [*संख्या*], [*रकम*]
  ),
  ..render-rows(data.at("table_securities", default: ()), 1, securities-mapper)
)

#if data.at("break_loan", default: false) [ #pagebreak() ] else [ #v(5pt) ]
*(घ) ऋण लिए/दिए/तिरेको विवरण*

#let loan-mapper(sn, item) = {
  if item != none {
    let t = item.at("loan_type", default: "")
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("borrower_lender_name_address", default: ""))],
      [#if t == "taken" [*✓*] else []],
      [#if t == "given" [*✓*] else []],
      [#if t == "repaid" [*✓*] else []],
      [#cv(item.at("amount", default: ""))],
      [#cv(item.at("date", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 3fr, 40pt, 40pt, 40pt, 70pt, 70pt, 1fr),
  align: (col, row) => if col == 0 or (row < 2) or (col >= 2 and col <= 4) { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    table.cell(rowspan: 2)[*क्र.सं.*],
    table.cell(rowspan: 2)[*ऋण लिने/दिने/तिर्ने व्यक्ति/संस्थाको नाम, ठेगाना*],
    table.cell(colspan: 3)[*ऋण*],
    table.cell(rowspan: 2)[*ऋण लिए/दिए/तिरेको रकम*],
    table.cell(rowspan: 2)[*ऋण लिए/दिए/तिरेको मिति*],
    table.cell(rowspan: 2)[*कैफियत*],
    
    [*लिएको*], [*दिएको*], [*तिरेको*]
  ),
  ..render-rows(data.at("table_loan", default: ()), 1, loan-mapper)
)

#if data.at("break_vehicles", default: false) [ #pagebreak() ] else [ #v(5pt) ]
*(ङ) सवारी साधन (अटोमोवाइलको हकमा मात्र) को विवरण*

#let vehicles-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("owner_name", default: ""))],
      [#cv(item.at("type_no", default: ""))],
      [#cv(item.at("price", default: ""))],
      [#cv(item.at("date", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 2.2fr, 2.8fr, 70pt, 70pt, 1.5fr, 1fr),
  align: (col, row) => if col == 0 or row == 0 { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    [*क्र.सं.*], [*सवारी धनीको नाम*], [*सवारीको किसिम र नम्बर*], [*खरीद मूल्य*], [*खरीद मिति*], [*प्राप्तिको स्रोत*], [*कैफियत*]
  ),
  ..render-rows(data.at("table_vehicles", default: ()), 1, vehicles-mapper)
)

#if data.at("break_agriculture", default: false) [ #pagebreak() ] else [ #v(5pt) ]
== ३. कृषि तथा पशुधन (घरजग्गा बाहेक) को विवरण

#let agriculture-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("details", default: ""))],
      [#cv(item.at("quantity", default: ""))],
      [#cv(item.at("price", default: ""))],
      [#cv(item.at("date", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 3fr, 45pt, 70pt, 70pt, 1.5fr, 1fr),
  align: (col, row) => if col == 0 or row == 0 { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    [*क्र.सं.*], [*विवरण*], [*संख्या*], [*खरीद मूल्य*], [*प्राप्त मिति*], [*प्राप्तिको स्रोत*], [*कैफियत*]
  ),
  ..render-rows(data.at("table_agriculture", default: ()), 1, agriculture-mapper)
)

#if data.at("break_others", default: false) [ #pagebreak() ] else [ #v(5pt) ]
== ४. अन्य सम्पत्तिको विवरण

#let others-mapper(sn, item) = {
  if item != none {
    (
      [#to-nepali-num(sn)],
      [#cv(item.at("details", default: ""))],
      [#cv(item.at("price", default: ""))],
      [#cv(item.at("date", default: ""))],
      [#cv(item.at("source", default: ""))],
      [#cv(item.at("remarks", default: ""))],
    )
  } else {
    ([#to-nepali-num(sn)], [], [], [], [], [])
  }
}

#table(
  columns: (25pt, 3.5fr, 70pt, 70pt, 1.5fr, 1fr),
  align: (col, row) => if col == 0 or row == 0 { center + horizon } else { left + horizon },
  stroke: 0.5pt,
  table.header(
    [*क्र.सं.*], [*विवरण*], [*खरीद मूल्य*], [*प्राप्त मिति*], [*प्राप्तिको स्रोत*], [*कैफियत*]
  ),
  ..render-rows(data.at("table_others", default: ()), 1, others-mapper)
)

#v(30pt)
मैले जाने बुझेसम्म माथि लेखिए बमोजिमको विवरण ठिक छ । फरक पर्ने छैन ।

#v(10pt)
#align(center)[
  #box(width: 250pt)[
    #grid(
      columns: (1fr),
      row-gutter: 10pt,
      align: left,
      [नाम :- #f(data.at("decl_name", default: ""))],
      [पद :- #f(data.at("decl_pad", default: ""))],
      [दस्तखत :-],
      [मिति :- #f(data.at("decl_miti", default: ""))]
    )
  ]
]

#v(30pt)
*द्रष्टव्य:* अघिल्लो आर्थिक वर्षमा पेश गरेको सम्पत्ति विवरणमा थपघट भएको विवरण यसै बमोजिमको फाराममा भरी पेश गर्नु पर्नेछ ।