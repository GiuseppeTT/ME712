my_get_mixed_linear_model_data <- function(
    experiment_data
) {
    experiment_data %>%
        filter(day != 0) %>% # There is no variability
        filter(not(is.na(weight)))
}

my_fit_mixed_linear_model <- function(
    mixed_linear_model_data
) {
    nlme::lme(
        fixed = weight ~ 1 + treatment + day + treatment:day,
        data = mixed_linear_model_data,
        random = ~ 1 + day | mouse,
        correlation = nlme::corAR1(form = ~ day | mouse),
        control = nlme::lmeControl(opt = "optim") # nlminb doesn't converge
    )
}

my_plot_mixed_linear_model_fit <- function(
    mixed_linear_model
) {
    mixed_linear_model %>%
        broom.mixed::augment() %>%
        my_translate_values() %>%
        ggplot(aes(x = day, color = treatment)) +
        geom_point(aes(y = weight), alpha = 0.5) +
        geom_line(aes(y = .fitted), size = 1) +
        scale_x_continuous(breaks = seq(0, 21, 3)) +
        scale_y_continuous(
            breaks = seq(0.7, 1.4, 0.1),
            labels = scales::label_percent(accuracy = 1),
            limits = c(0.7, 1.4)
        ) +
        ggthemes::scale_color_colorblind() +
        guides(colour = guide_legend(override.aes = list(size = 5))) +
        theme_bw(base_size = 22) +
        labs(
            x = "Dias após infecção",
            y = "Porcentagem do peso inicial",
            color = "Tratamento"
        )
}

my_tabularize_fixed_effect_parameters <- function(
    mixed_linear_model
) {
    fixed_effect_parameters <-
        mixed_linear_model %>%
        broom.mixed::tidy() %>%
        filter(effect == "fixed")

    fixed_effect_parameters <-
        fixed_effect_parameters %>%
        mutate(term = str_remove_all(term, "treatment")) %>%
        mutate(p.value = p.adjust(p.value))

    fixed_effect_parameters <-
        fixed_effect_parameters %>%
        select(term, estimate, std.error, df, statistic, p.value) %>%
        my_translate_values() %>%
        my_translate_columns()

    fixed_effect_parameters
}

.get_lme_phi <- function(
    lme_model
) {
    lme_model %>%
        extract2("modelStruct") %>%
        extract2("corStruct") %>%
        coef(unconstrained = FALSE) %>%
        as.numeric()
}

my_tabularize_variability_parameters <- function(
    mixed_linear_model
) {
    variability_parameters <-
        mixed_linear_model %>%
        broom.mixed::tidy() %>%
        filter(effect == "ran_pars")

    variability_parameters <-
        variability_parameters %>%
        mutate(term = str_replace_all(term, c("_" = " ", "\\." = " vs ")))

    variability_parameters <-
        variability_parameters %>%
        add_row(
            term = "autocor Observation",
            estimate = .get_lme_phi(mixed_linear_model)
        )

    variability_parameters <-
        variability_parameters %>%
        select(term, estimate) %>%
        my_translate_values() %>%
        my_translate_columns()

    variability_parameters
}

my_plot_mixed_linear_model_residuals <- function(
    mixed_linear_model
) {
    mixed_linear_model %>%
        broom.mixed::augment() %>%
        mutate(.resid = residuals(mixed_linear_model, type = "normalized")) %>%
        ggplot(aes(x = .fitted, y = .resid)) +
        geom_point() +
        ggthemes::scale_color_colorblind() +
        theme_bw(base_size = 22) +
        labs(
            x = "Valor ajustado",
            y = "Resíduo"
        )
}
