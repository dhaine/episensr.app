#' @import shiny
app_server <- function(input, output,session) {
    # List the first level callModules here
    ## version
    output$versioning <- renderPrint(packageVersion("episensr"))
}
