# Current limitation is that the images that are used are relative to the package lib.loc / help so what might be idea lis to extract the image and base64 encode them using {b64}
pkg_to_mdx <- function(pkg, out_path = paste0(pkg, ".qmd"), ...) {
  tmp <- tempfile()
  base_doc <- tools::pkg2HTML(pkg, out = tmp, include_description = FALSE)

  # read in html
  og <- rvest::read_html(tmp)

  # get all of the elements
  all_elements <- og |>
    rvest::html_elements("main") |>
    rvest::html_children()

  # get reference positions
  reference_starts <- which(rvest::html_name(all_elements) == "h2" & !is.na(rvest::html_attr(all_elements, "id")))

  # count how many elements there are in the html file
  n <- length(all_elements)

  # identify the reference section ending positions
  reference_ends <- (reference_starts + diff(c(reference_starts, n))) - 1
  reference_ends[length(reference_ends)] <- length(all_elements)

  # extract all of the reference doc
  all_references <- Map(
    function(.x, .y) {
      # create a new html div with a "reference class"
      new_div <- rvest::read_html('<div class="reference"></div>') |>
        rvest::html_element("div")

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
  yaml_header <- glue::glue("---
title: {pkg}
---")
  # cleaned <- gsub("<(http[^>]+|[^>]+@[^>]+)>", "\\1", all_mds, perl = TRUE)
  # cleaned <- stringr::str_remove_all(cleaned, 'style\\s*=\\s*(["\'])(.*?)\\1') |>
  #   stringr::str_replace_all("><", ">\n<") |>
  #   stringr::str_replace_all(">([^<])", ">\n\\1") |>
  #   stringr::str_replace_all("([^>])<", "\\1\n<")
  cleaned <- gsub("<(http[^>]+|[^>]+@[^>]+)>", "\\1", all_mds, perl = TRUE)

  cleaned <- cleaned |>
    stringr::str_remove_all('style\\s*=\\s*(["\'])(.*?)\\1') |>
    stringr::str_replace_all("(?<!<-|\\\\)><", ">\n<") |>
    stringr::str_replace_all("(?<!<-|\\\\)>([^<])", ">\n\\1") |>
    stringr::str_replace_all("([^>])(?<!<-|\\\\)<", "\\1\n<") |>
    stringr::str_replace_all("<code[^>]*>[\\s\\S]*?</code>", function(x) gsub("\n", "", x)) |>
    stringr::str_replace_all(" \n<-", " <-")

  # c(yaml_header, all_mds)
  # write the file out
  brio::write_lines(
    # this removes the complicated brackets for jsx
    c(yaml_header, cleaned),
    out_path
  )
}

# converts a reference to github flavored markdown
# this doesnt create the ::: classes though so it wont be compatible
# with JSX...
html_to_md <- function(reference) {
  pandoc::pandoc_convert(
    text = reference,
    from = "html",
    to = "gfm",
    args = "--wrap=none"
  )
}

# pkg_to_mdx("arcgisutils", "~/github/misc-esri/dev-docs/arcgisutils.mdx")
# file.edit("~/github/misc-esri/dev-docs/arcgisutils.mdx")

# the results of this will not be perfect so first it needs to be linted with prettier..maybe not
pkg_to_mdx("arcgislayers", "~/github/misc-esri/dev-docs/arcgislayers.mdx")
pkg_to_mdx("arcgisutils", "~/github/misc-esri/dev-docs/arcgisutils.mdx")
pkg_to_mdx("arcpbf", "~/github/misc-esri/dev-docs/arcpbf.mdx")
pkg_to_mdx("arcgisgeocode", "~/github/misc-esri/dev-docs/arcgisgeocode.mdx")
