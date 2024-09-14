// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}

#let poster(
  // The poster's size.
  size: "'36x24' or '48x36''",

  // The poster's title.
  title: "Paper Title",

  // A string of author names.
  authors: "Author Names (separated by commas)",

  // Department name.
  departments: "Department Name",

  // University logo.
  univ_logo: "Logo Path",

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
  footer_text: "Footer Text",

  // Any URL, like a link to the conference website.
  footer_url: "Footer URL",

  // Email IDs of the authors.
  footer_email_ids: "Email IDs (separated by commas)",

  // Color of the footer.
  footer_color: "Hex Color Code",

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  keywords: (),

  // Number of columns in the poster.
  num_columns: "3",

  // University logo's scale (in %).
  univ_logo_scale: "70",

  // University logo's column size (in in).
  univ_logo_column_size: "10",

  // Title and authors' column size (in in).
  title_column_size: "20",

  // Poster title's font size (in pt).
  title_font_size: "48",

  // Authors' font size (in pt).
  authors_font_size: "36",

  // Footer's URL and email font size (in pt).
  footer_url_font_size: "30",

  // Footer's text font size (in pt).
  footer_text_font_size: "24",

  // The poster's content.
  body
) = {
  // Set the body font.
  set text(font: "STIX Two Text", size: 18pt)
  let sizes = size.split("x")
  let width = int(sizes.at(0)) * 1in
  let height = int(sizes.at(1)) * 1in
  univ_logo_scale = int(univ_logo_scale) * 1%
  title_font_size = int(title_font_size) * 1pt
  authors_font_size = int(authors_font_size) * 1pt
  num_columns = int(num_columns)
  univ_logo_column_size = int(univ_logo_column_size) * 1in
  title_column_size = int(title_column_size) * 1in
  footer_url_font_size = int(footer_url_font_size) * 1pt
  footer_text_font_size = int(footer_text_font_size) * 1pt

  // Configure the page.
  // This poster defaults to 36in x 24in.
  set page(
    width: width,
    height: height,
    margin: 
      (top: 1in, left: 2in, right: 2in, bottom: 2in),
    footer: [
      #set align(center)
      #set text(32pt)
      #block(
        fill: rgb(footer_color),
        width: 100%,
        inset: 20pt,
        radius: 10pt,
        [
          #text(font: "Courier", size: footer_url_font_size, footer_url) 
          #h(1fr) 
          #text(size: footer_text_font_size, smallcaps(footer_text)) 
          #h(1fr) 
          #text(font: "Courier", size: footer_url_font_size, footer_email_ids)
        ]
      )
    ]
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "I.A.1.")
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(24pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      #set align(center)
      #set text({ 32pt })
      #show: smallcaps
      #v(50pt, weak: true)
      #if it.numbering != none {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(35.75pt, weak: true)
      #line(length: 100%)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set text(style: "italic")
      #v(32pt, weak: true)
      #if it.numbering != none {
        numbering("i.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering("1)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  })

  // Arranging the logo, title, authors, and department in the header.
  align(center,
    grid(
      rows: 2,
      columns: (univ_logo_column_size, title_column_size),
      column-gutter: 10pt,
      row-gutter: 20pt,
      image(univ_logo, width: univ_logo_scale),
      text(title_font_size, title + "\n\n") + 
      text(authors_font_size, emph(authors) + departments),
    )
  )

  // Start three column mode and configure paragraph properties.
  show: columns.with(num_columns, gutter: 64pt)
  set par(justify: true, first-line-indent: 0em)
  show par: set block(spacing: 0.65em)

  // Display the keywords.
  if keywords != () [
      #set text(24pt, weight: 400)
      #show "Keywords": smallcaps
      *Keywords* --- #keywords.join(", ")
  ]

  // Display the poster's contents.
  body
 
}
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => poster(
   title: [Visualization of Choropleth Map of Resident Population Density in Singapore], 
  // TODO: use Quarto's normalized metadata.
   authors: [Azreen, Kai Jun, Aloysius, Irfan, Beata], 
   departments: [~], 
   size: "36x24", 

  // Institution logo.
   univ_logo: "./images/sit.png", 

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
   footer_text: [AAI1001 AY23/24 Tri 3 Team Project], 

  // Any URL, like a link to the conference website.
   footer_url: [~], 

  // Emails of the authors.
   footer_email_ids: [Team 03], 

  // Color of the footer.
   footer_color: "ebcfb2", 

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  

  // Number of columns in the poster.
  

  // University logo's scale (in %).
  

  // University logo's column size (in in).
  

  // Title and authors' column size (in in).
  

  // Poster title's font size (in pt).
  

  // Authors' font size (in pt).
  

  // Footer's URL and email font size (in pt).
  

  // Footer's text font size (in pt).
  

  doc,
)


= Introduction
<introduction>
The geographical distribution of Singapore’s population is crucial in urban studies and public policy. Our project examines how demographic characteristics relate to urban planning policies, as illustrated in Figure 1. This visualization, based on data from the Singapore Department of Statistics \(2023), highlights significant demographic changes. Commended for its clarity, our work can be enhanced with interactive elements, expanded temporal ranges, and detailed geospatial mappings. These improvements will offer a more comprehensive view of how urban planning impacts population distribution and housing patterns in Singapore.

= Previous Visualisation
<previous-visualisation>
#figure([
#box(width: 70%,image("images/Figure1.PNG"))
], caption: figure.caption(
position: bottom, 
[
Visualization of Choropleth Map of Resident Population Density by the Department of Statistics Singapore \(Singstat 2023)
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-label>


= Strengths
<strengths>
The Choropleth map contains several variables: population distribution \(quantitative) and planning areas \(categorical). Additionally, the visualization includes a heatmap that allow users to delve into subzones to see pattern in land development and population over time.

= Suggested Improvements
<suggested-improvements>
+ Better contrast: Utilize high-contrast colors to improve accessibility for users with visual impairments, ensuring clarity and ease of interpretation for all users. One such example is the use of Color Universal Design \(CUD) colors which are designed to be distinguishable by all users, including those with color vision deficiencies. \(#link("https://jfly.uni-koeln.de/color/")[Okabe and Ito 2008];)

+ Reduced Data Density: Simplify the presentation by reducing the number of data points displayed simultaneously, thus preventing overcrowding and making the visualization more comprehensible.

+ Interactive Elements: Hovering over a country will display a tooltip with detailed information on the population size of a certain region of Singapore as well as the age profile.

+ Expanded Temporal Ranges: Introduce options for users to select specific time periods for analysis, facilitating a deeper exploration of trends over time.

= Implementation
<implementation>
== Data Sources
<data-sources>
- Weekly counts of population data by planning area were obtained from the Singapore Department of Statistics. The data includes the total population, age groups, and planning areas for each year. Data Source from \(#link("https://www.singstat.gov.sg/find-data/search-by-theme/population/geographic-distribution/latest-data")[Singapore Department of Statistics];)
- The geospatial data for the planning areas was obtained from the Master Plan 2019 Planning Area Boundary KML file. Data Source from \(#link("https://www.ura.gov.sg/maps/#master-plan")[Urban Redevelopment Authority \(URA)];)

== Software
<software>
- #emph[dplyr] package is used for data manipulation
- #emph[leaflet] package is used for creating interactive maps
- #emph[sf] package is used for handling spatial data
- #emph[shiny] package is used for building interactive web applications

= Improved Visualisation
<improved-visualisation>
#figure([
#box(width: 75%,image("images/DataVisualization.png"))
], caption: figure.caption(
position: bottom, 
[
Visualization of improved Choropleth Map of Resident Population Density by the Department of Statistics Singapore \(Singstat 2023)
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


= Further Suggestions for Interactivity
<further-suggestions-for-interactivity>
We propose implementing dynamic UI updates, such as changing the map title or legend based on the selected age group or year. Additionally, using 'shinycssloaders' will provide loading animations while data is being processed or the map is being updated. Furthermore, offering options for users to download filtered data and visualizations as images or CSV files would significantly enhance the user experience.

Another recommendation is to implement conditional highlighting on the map based on user-defined criteria, such as highlighting areas with population growth above a certain percentage or areas with a high density of elderly residents. Finally, integrating a time slider with play/pause controls would allow users to see changes over time automatically, providing a more interactive and informative experience.

= Conclusion
<conclusion>
The plot can effectively communicate the relationship between the population density in each region of Singapore over time, and additionally allow curious readers to explore the data even further using interactivity.

= References
<references>
+ Arnold, M., Goldschmitt, M., & Rigotti, T. \(2023, June 21). Dealing with information overload: A comprehensive review. Frontiers in psychology. https:\/\/www.ncbi.nlm.nih.gov/pmc/articles/PMC10322198/

+ Department of Statistics Singapore. \(2000 - 2023). Singapore Residents by Planning Area / Subzone, Single Year of Age and Sex \(June 2000-2010, June 2011-2020, June 2021, June 2022, June 2023) \[Data set\]. https:\/\/www.singstat.gov.sg/find-data/search-by-theme/population/geographic-distribution/latest-data

+ Okabe, M., & Ito, K. \(2008). Color Universal Design \(CUD): How to make figures and presentations that are friendly to Colorblind people. https:\/\/jfly.uni-koeln.de/color/

+ Singapore Department of Statistics. \(2023). Population Trends 2023. https:\/\/www.singstat.gov.sg/-/media/files/publications/population/population2023.ashx

+ Urban Redevelopment Authority \(URA). \(2019). Master Plan 2019 Planning Area Boundary KML. https:\/\/www.ura.gov.sg/maps/\#master-plan
