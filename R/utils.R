source_directory <- function(
    path,
    ...
) {
    path %>%
        dir_ls(type = "file", ...) %>%
        walk(source)
}
