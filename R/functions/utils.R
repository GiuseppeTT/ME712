TRANSLATIONS <- c(
    # Values
    "Wild" = "Selvagem",
    "Alive" = "Vivo",
    "Dead" = "Morto",
    "Intercept" = "Intercepto",
    "day" = "Dia",
    "Observation" = "Erro",
    "sd " = "Desvio Padrão ",
    "autocor " = "Autocorrelação ",
    "cor " = "Correlação ",
    "treatment" = "Tratamento",

    # Columns
    "term" = "Parâmetro",
    "estimate" = "Estimativa",
    "std.error" = "Erro padrão",
    "df" = "G.L.",
    "statistic" = "Estatística",
    "p.value" = "p-valor",
    "pair" = "Par"
)

.fill_empty_with_previous <- function(
    previous_value,
    current_value
) {
    if (current_value == "")
        return(previous_value)
    else
        return(current_value)
}

# Repair merged cell column names for read_excel
#
# An excel sheet with merged cells at column names such as
#    a   | b |    c
# -------|---|---------
#  1 2 3 | T | "w" "x"
#  4 5 6 | F | "y" "z"
#
# produces the following pattern in column names when read by read_excel
# c("a", "", "", "b", "c", "")
#
# which this function tries to fix by using the previous available name, as
# given by
# c("a", "a", "a", "b", "c", "c")
repair_merged_cell_names <- function(
    cell_names
) {
    cell_names %>%
        accumulate(.fill_empty_with_previous)
}

.my_translate_characters <- function(
    characters
) {
    characters %>%
        str_replace_all(TRANSLATIONS)
}

.my_translate_factors <- function(
    factors
) {
    factors %>%
        fct_relabel(.my_translate_characters)
}

# Translate the values of a data frame to Portuguese. This is used for reporting
my_translate_values <- function(
    data
) {
    data %>%
        mutate(across(where(is_character), .my_translate_characters)) %>%
        mutate(across(where(is.factor), .my_translate_factors))
}

# Translate the columns of a data frame to Portuguese. This is used for
# reporting
my_translate_columns <- function(
    data
) {
    translated_columns <-
        data %>%
        colnames() %>%
        .my_translate_characters()

    data %>%
        set_colnames(translated_columns)
}

# https://stackoverflow.com/questions/49532418/reuse-r-code-with-knitr-in-rnw-sweave-files
.knit_parametrized <- function(
    parameters,
    ...
) {
    # Parent enviroment needs to be globalenv, otherwise library() won't work
    knitr::knit(envir = list2env(parameters, parent = globalenv()), ...)
}

# Pass parameters to .Rnw as variables through an enviroment. This is done to
# reproduce the params argument in rmarkdown::render().
#
# https://stackoverflow.com/questions/32257970/knitr-inherits-variables-from-a-users-environment-even-with-envir-new-env
knit_parametrized <- function(
    ...
) {
    # .knit_parametrized needs to be run in another session (callr::r()) to
    # prevent globalenv from leeking into knit files
    .knit_parametrized %>%
        callr::r(args = list(...), show = TRUE)
}

my_render_sweave <- function(
    source_path,
    output_path,
    parameters = list(),
    engine = "pdflatex",
    keep_intermediate_file = FALSE
) {
    if (keep_intermediate_file)
        intermediate_file <- path_ext_set(source_path, "tex")
    else
        intermediate_file <- file_temp(ext = "tex")

    source_path %>%
        knit_parametrized(parameters = parameters, output = intermediate_file) %>%
        tinytex::latexmk(pdf_file = output_path, engine = engine)
}
