plan <- drake_plan(
    # Data cleaning
    experiment_data = my_clean_data(
        file_in(!!paths$researcher_data)
    ),
)
