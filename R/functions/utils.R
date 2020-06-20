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
