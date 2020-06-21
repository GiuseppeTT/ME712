my_get_survival_analysis_data <- function(
    experiment_data
) {
    survival_analysis_data <-
        experiment_data %>%
        filter(not(is.na(weight)))

    survival_analysis_data <-
        survival_analysis_data %>%
        group_by(treatment, mouse) %>%
        summarise(death_day = max(day) + 1) %>%
        ungroup()

    survival_analysis_data <-
        survival_analysis_data %>%
        mutate(died = death_day < 22 )

    survival_analysis_data  <-
        survival_analysis_data %>%
        select(treatment, death_day, died) %>%
        arrange(treatment, death_day)

    survival_analysis_data
}

my_plot_survival_curves <- function(
    survival_analysis_data
) {
    curve_data <-
        survival_analysis_data %>%
        survival::survfit(survival::Surv(death_day, died) ~ treatment, data = .) %>%
        broom::tidy()

    curve_data <-
        curve_data %>%
        mutate(strata = str_remove_all(strata, "treatment=")) %>%
        add_row(time = 0, estimate = 1, strata = c("Wild", "RAG1", "RAG2"))

    curve_data <-
        curve_data %>%
        mutate(strata = fct_relevel(strata, c("Wild", "RAG1", "RAG2"))) %>%
        my_translate_values()

    curve_plot <-
        curve_data %>%
        ggplot(aes(x = time, y = estimate, color = strata)) +
        geom_step(size = 1.5) +
        scale_x_continuous(breaks = seq(0, 21, 3)) +
        scale_y_continuous(labels = scales::percent) +
        ggthemes::scale_color_colorblind() +
        guides(colour = guide_legend(override.aes = list(size = 5))) +
        theme_bw(base_size = 22) +
        labs(
            x = "Dias após infecção",
            y = "Porcentagem de sobreviventes",
            color = "Tratamento"
        )

    curve_plot
}

my_tabularize_log_rank_test <- function(
    survival_analysis_data
) {
    log_rank_test_table <-
        survival_analysis_data %>%
        survival::survdiff(survival::Surv(death_day, died) ~ treatment, data = .) %>%
        broom::glance()

    log_rank_test_table <-
        log_rank_test_table %>%
        my_translate_columns()

    log_rank_test_table
}

my_tabularize_pairwise_log_rank_tests <- function(
    survival_analysis_data
) {
    pairwise_log_rank_tests_table <-
        survival_analysis_data %>%
        survminer::pairwise_survdiff(
            survival::Surv(death_day, died) ~ treatment,
            data = .,
            p.adjust.method = "none"
        ) %>%
        extract2("p.value") %>%
        as_tibble(rownames = "treatment 1")

    pairwise_log_rank_tests_table <-
        pairwise_log_rank_tests_table %>%
        pivot_longer(-`treatment 1`, names_to = "treatment 2", values_to = "p.value") %>%
        filter(not(is.na(`p.value`))) %>%
        mutate(p.value = p.adjust(p.value))

    pairwise_log_rank_tests_table <-
        pairwise_log_rank_tests_table %>%
        mutate(pair = str_c(`treatment 2`, `treatment 1`, sep = " vs "))

    pairwise_log_rank_tests_table <-
        pairwise_log_rank_tests_table %>%
        select(pair, `p.value`) %>%
        my_translate_columns() %>%
        my_translate_values()

    pairwise_log_rank_tests_table
}
