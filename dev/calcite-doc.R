# Current limitation is that the images that are used are relative to the package lib.loc / help so what might be idea lis to extract the image and base64 encode them using {b64}
pkg_to_quarto_doc <- function(pkg, out_path = paste0(pkg, ".qmd"), ...) {
  tmp <- tempfile()
  base_doc <- tools::pkg2HTML(pkg, out = tmp, ...)

  # read in html
  og <- rvest::read_html(tmp)

  # identify all spans—these should be removed
  spans_to_remove <- rvest::html_elements(og, "span")

  # remove all the spans
  for (span in spans_to_remove) {
    xml2::xml_remove(span)
  }

  # get all of the elements
  all_elements <- og |>
    html_elements("main") |>
    html_children()

  # get reference positions
  reference_starts <- which(html_name(all_elements) == "h2" & !is.na(html_attr(all_elements, "id")))

  # count how many elements there are in the html file
  n <- length(all_elements)

  # identify the reference section ending positions
  reference_ends <- (reference_starts + diff(c(reference_starts, n))) - 1
  reference_ends[length(reference_ends)] <- length(all_elements)

  # extract all of the reference doc
  all_references <- Map(
    function(.x, .y) {
      # create a new html div with a "reference class"
      new_div <- read_html('<div class="reference"></div>') |>
        html_element("div")

      # identify all of the children from the reference section
      children <- all_elements[.x:.y]

      # for each of the children add it to the div
      for (child in children) {
        xml2::xml_add_child(new_div, child)
      }
      # return the div
      new_div
    },
    reference_starts, reference_ends
  )

  all_mds <- unlist(lapply(all_references, html_to_md))

  # add a quarto yaml header
  # adds the TOC to mimic the R function
  yaml_header <- "---
format:
  html:
    toc: true
eval: false
---"
  # write the file out
  brio::write_lines(c(yaml_header, all_mds), out_path)
}

# converts a reference to github flavored markdown
# this doesnt create the ::: classes though so it wont be compatible
# with JSX...
html_to_md <- function(reference) {
  pandoc::pandoc_convert(
    text = reference,
    from = "html",
    to = "gfm"
  )
}


pkg_to_quarto_doc("vctrs", "dev/vctrs.qmd")
