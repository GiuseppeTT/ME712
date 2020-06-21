my_get_simultaneous_anovas_data <- function(
    experiment_data
) {
    simultaneous_anovas_data <-
        experiment_data %>%
        filter(day != 0) %>% # There is no variability
        filter(not(is.na(weight)))

    simultaneous_anovas_data <-
        simultaneous_anovas_data %>%
        group_by(day) %>%
        filter(n_distinct(treatment) == 3) %>% # Need every treatment available
        ungroup()

    simultaneous_anovas_data
}

my_fit_simultaneous_anovas <- function(
    simultaneous_anovas_data
) {
    simultaneous_anovas <-
        simultaneous_anovas_data %>%
        nest(data = c(treatment, mouse, life_status, weight))

    simultaneous_anovas <-
        simultaneous_anovas %>%
        rowwise() %>%
        mutate(linear_model =
            lm(weight ~ treatment, data = data) %>%
            list()
        ) %>%
        ungroup()

    simultaneous_anovas <-
        simultaneous_anovas %>%
        select(day, linear_model)

    simultaneous_anovas
}

my_plot_simultaneous_anovas_fit <- function(
    simultaneous_anovas
) {
    fit_data <-
        simultaneous_anovas %>%
        rowwise() %>%
        mutate(fit_data =
            linear_model %>%
            broom::augment() %>%
            list()
        ) %>%
        ungroup() %>%
        unnest(fit_data)

    fit_data <-
        fit_data %>%
        my_translate_values()

    fit_plot <-
        fit_data %>%
        ggplot(aes(x = factor(day), color = treatment)) +
        geom_point(aes(y = .fitted), size = 3, position = position_dodge(width = 1)) +
        geom_errorbar(
            aes(ymin = .fitted - .se.fit, ymax = .fitted + .se.fit),
            size = 1,
            width = 0.75,
            position = position_dodge(width = 1)
        ) +
        scale_y_continuous(
            breaks = seq(0.70, 1.20, 0.1),
            labels = scales::label_percent(accuracy = 1),
            limits = c(0.65, 1.25)
        ) +
        ggthemes::scale_color_colorblind() +
        guides(colour = guide_legend(override.aes = list(size = 5))) +
        theme_bw(base_size = 22) +
        labs(
            x = "Dias após infecção",
            y = "Porcentagem do peso inicial",
            color = "Tratamento"
        )

    fit_plot
}

my_tabularize_F_tests <- function(
    simultaneous_anovas
) {
    F_tests_table <-
        simultaneous_anovas %>%
        rowwise() %>%
        mutate(F_test =
            linear_model %>%
            anova() %>%
            broom::tidy() %>%
            list()
        ) %>%
        ungroup() %>%
        unnest(F_test)

    F_tests_table <-
        F_tests_table %>%
        filter(term != "Residuals") %>%
        mutate(p.value = p.adjust(p.value))

    F_tests_table <-
        F_tests_table %>%
        select(day, term, df, statistic, p.value) %>%
        my_translate_values() %>%
        my_translate_columns()

    F_tests_table
}

my_tabularize_pairwise_t_tests <- function(
    simultaneous_anovas
) {
    pairwise_t_tests_table <-
        simultaneous_anovas %>%
        rowwise() %>%
        mutate(fit_data =
            linear_model %>%
            broom::augment() %>%
            list()
        ) %>%
        mutate(pairwise_t_tests_data =
            pairwise.t.test(fit_data$weight, fit_data$treatment, p.adjust.method = "none") %>%
            broom::tidy() %>%
            list()
        ) %>%
        ungroup() %>%
        unnest(pairwise_t_tests_data)

    pairwise_t_tests_table <-
        pairwise_t_tests_table %>%
        mutate(p.value = p.adjust(p.value))

    pairwise_t_tests_table <-
        pairwise_t_tests_table %>%
        pivot_wider(
            id_cols = day,
            names_from = c(group1, group2),
            names_sep = " vs ",
            values_from = p.value
        )

    pairwise_t_tests_table <-
        pairwise_t_tests_table %>%
        my_translate_values() %>%
        my_translate_columns()

    pairwise_t_tests_table
}

my_tabularize_shapiro_tests <- function(
    simultaneous_anovas
) {
    shapiro_tests_table <-
        simultaneous_anovas %>%
        rowwise() %>%
        mutate(fit_data =
            linear_model %>%
            broom::augment() %>%
            list()
        ) %>%
        mutate(shapiro_test_data =
            shapiro.test(fit_data$.resid) %>%
            broom::tidy() %>%
            list()
        ) %>%
        ungroup() %>%
        unnest(shapiro_test_data)

    shapiro_tests_table <-
        shapiro_tests_table %>%
        mutate(p.value = p.adjust(p.value))

    shapiro_tests_table <-
        shapiro_tests_table %>%
        select(day, statistic, p.value) %>%
        my_translate_columns()

    shapiro_tests_table
}

my_tabularize_levene_tests <- function(
    simultaneous_anovas
) {
    levene_tests_table <-
        simultaneous_anovas %>%
        rowwise() %>%
        mutate(fit_data =
            linear_model %>%
            broom::augment() %>%
            list()
        ) %>%
        mutate(levene_test_data =
            car::leveneTest(fit_data$weight, fit_data$treatment) %>%
            broom::tidy() %>%
            list()
        ) %>%
        ungroup() %>%
        unnest(levene_test_data)

    levene_tests_table <-
        levene_tests_table %>%
        filter(term == "group") %>%
        mutate(p.value = p.adjust(p.value))

    levene_tests_table <-
        levene_tests_table %>%
        select(day, df, statistic, p.value) %>%
        my_translate_columns()

    levene_tests_table
}
