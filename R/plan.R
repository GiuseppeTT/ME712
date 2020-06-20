plan <- drake_plan(
    # Data cleaning
    experiment_data = my_clean_data(
        file_in(!!paths$researcher_data)
    ),

    # Descriptive analysis
    weights_plot = my_plot_weights(
        experiment_data
    ),
    life_status_plot = my_plot_life_status(
        experiment_data
    ),
)
