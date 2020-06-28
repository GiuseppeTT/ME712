my_generate_presentation <- function(
    source_path,
    output_path,
    parameters
) {
    my_render_sweave(source_path, output_path, parameters, engine = "xelatex")
}
