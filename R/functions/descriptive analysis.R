my_plot_weights <- function(
    experiment_data
) {
    experiment_data %>%
        my_translate_values() %>%
        ggplot(aes(x = day, y = weight, color = treatment, group = mouse)) +
        geom_line(alpha = 0.5, size = 1.5) +
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

my_plot_life_status <- function(
    experiment_data
) {
    experiment_data %>%
        my_translate_values() %>%
        ggplot(aes(x = day, fill = life_status)) +
        geom_bar(position = "fill") +
        facet_grid(vars(treatment)) +
        scale_x_continuous(breaks = seq(0, 21, 3), expand = c(0, 0)) +
        scale_y_continuous(
            breaks = c(0, 0.5, 1),
            labels = scales::label_percent(),
            expand = c(0, 0)
        ) +
        scale_fill_grey(start = 0.8, end = 0.2) +
        theme_bw(base_size = 22) +
        theme(panel.spacing = unit(1.5, "lines")) +
        labs(
            x = "Dias após infecção",
            y = "Porcentagem de ratos vivos/mortos",
            fill = "Estado de vida"
        )
}
