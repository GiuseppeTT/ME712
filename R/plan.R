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

    # Mixed linear model
    mixed_linear_model_data = my_get_mixed_linear_model_data(
        experiment_data
    ),
    mixed_linear_model = my_fit_mixed_linear_model(
        mixed_linear_model_data
    ),
    mixed_linear_model_fit_plot = my_plot_mixed_linear_model_fit(
        mixed_linear_model
    ),
    fixed_effect_parameters_table = my_tabularize_fixed_effect_parameters(
        mixed_linear_model
    ),
    variability_parameters_table = my_tabularize_variability_parameters(
        mixed_linear_model
    ),
    mixed_linear_model_residuals = my_plot_mixed_linear_model_residuals(
        mixed_linear_model
    ),

    # Simultaneous ANOVAs
    simultaneous_anovas_data = my_get_simultaneous_anovas_data(
        experiment_data
    ),
    simultaneous_anovas = my_fit_simultaneous_anovas(
        simultaneous_anovas_data
    ),
    simultaneous_anovas_fit_plot = my_plot_simultaneous_anovas_fit(
        simultaneous_anovas
    ),
    F_tests_table = my_tabularize_F_tests(
        simultaneous_anovas
    ),
    pairwise_t_tests_table = my_tabularize_pairwise_t_tests(
        simultaneous_anovas
    ),
    shapiro_tests_table = my_tabularize_shapiro_tests(
        simultaneous_anovas
    ),
    levene_tests_table = my_tabularize_levene_tests(
        simultaneous_anovas
    ),

    # Survival analysis
    survival_analysis_data = my_get_survival_analysis_data(
        experiment_data
    ),
    survival_curves_plot = my_plot_survival_curves(
        survival_analysis_data
    ),
    log_rank_table = my_tabularize_log_rank_test(
        survival_analysis_data
    ),
    pairwise_log_rank_tests_table = my_tabularize_pairwise_log_rank_tests(
        survival_analysis_data
    ),
)
