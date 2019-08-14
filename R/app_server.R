#' @import shiny
app_server <- function(input, output,session) {
    # List the first level callModules here
    ## version
    output$versioning <- renderPrint(packageVersion("episensr"))

    output$bias_choice <- renderUI({
                                      bias_file <- switch(input$type,
                                                          selection = "inst/app/www/selection_bias.md",
                                                          misclass = "inst/app/www/misclassification.md"
                                                          )
                                      includeMarkdown(bias_file)
                                  })

    output$two_by_two <- DT::renderDT(
                                 dat,
                                 selection = "none", 
                                 options = list(searching = FALSE,
                                                paging = FALSE,
                                                ordering = FALSE,
                                                dom = "t"), 
                                 server = FALSE,
                                 escape = FALSE,
                                 rownames = c("Cases", "Noncases"),
                                 colnames = c("Exposed", "Unexposed"),
                                 callback = JS("table.rows().every(function(i, tab, row) {
                  var $this = $(this.node());
                  $this.attr('id', this.data()[0]);
                  $this.addClass('shiny-input-container');
                  });
                  Shiny.unbindAll(table.table().node());
                  Shiny.bindAll(table.table().node());")
                  )
}
