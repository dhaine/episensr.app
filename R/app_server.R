#' @import shiny
app_server <- function(input, output,session) {
    # List the first level callModules here
    ## version
    output$versioning <- renderPrint(packageVersion("episensr"))

    output$bias_choice = renderUI({
                                      bias_file <- switch(input$type,
                                                          selection = "inst/app/www/selection_bias.md",
                                                          misclass = "inst/app/www/misclassification.md"
                                                          )
                                      includeMarkdown(bias_file)
                                  })
}
