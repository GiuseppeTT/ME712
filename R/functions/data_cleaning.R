.my_recode_treatment <- function(
    treatments
) {
    treatments %>%
        recode(WT = "Wild", Rag1 = "RAG1", Rag2 = "RAG2") %>%
        fct_relevel(c("Wild", "RAG1", "RAG2"))
}

.my_check_lifeness <- function(
    weights
) {
    weights %>%
        is.na() %>%
        if_else("Dead", "Alive") %>%
        fct_relevel(c("Alive", "Dead"))
}

.my_clean_weight <- function(
    weights
) {
    weights %>%
        divide_by(100) %>%
        na_if(0)
}

my_clean_data <- function(
    researcher_data_path
) {
    data <-
        researcher_data_path %>%
        read_excel(sheet = "Planilha2", .name_repair = repair_merged_cell_names)

    data <-
        data %>%
        pivot_longer(-`Days post infection`, names_to = "treatment", values_to = "weight") %>%
        rename(day = `Days post infection`)

    data <-
        data %>%
        group_by(day, treatment) %>%
        mutate(mouse = seq_len(n())) %>%
        ungroup()

    data <-
        data %>%
        mutate(treatment = .my_recode_treatment(treatment)) %>%
        mutate(mouse = str_c(treatment, mouse, sep = " ")) %>%
        mutate(weight = .my_clean_weight(weight)) %>%
        mutate(life_status = .my_check_lifeness(weight))

    data <-
        data %>%
        select(day, treatment, mouse, life_status, weight) %>%
        arrange(day, treatment, mouse)

    data
}
