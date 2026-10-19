default:
    just --list

fmt:
    air format R tests

lint:
    jarl check R tests && air format --check R tests

check:
    R -q -e "devtools::check()"

test:
    R -q -e "devtools::test()"

document:
    R -q -e "devtools::document()"

readme:
    quarto render README.Rmd
