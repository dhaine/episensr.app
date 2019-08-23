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

    # Initiate table
    previous <- reactive({DF})

    MyChanges <- reactive({
                              if(is.null(input$two_by_two)){return(previous())}
                              else if(!identical(previous(),input$two_by_two)){
      # hot.to.df function will convert your updated table into the dataframe
                                  mytable <- as.data.frame(hot_to_r(input$two_by_two))
                                  mytable
                              }
                          })
    output$two_by_two <- renderRHandsontable({rhandsontable(MyChanges(),
                                                            rowHeaderWidth = 200,
                                                            width = 400,
                                                           stretchH = "all"
                                                            )})

    episensrout = reactive({
                               mat <- as.matrix(MyChanges())
                               if (input$type == "selection") {
                                   mod <- selection(mat,
                                                    bias_parms = if (input$parms_controller == FALSE) {
                                                                     c(callModule(mod_parms_server, "parms_sel1"),
                                                                       callModule(mod_parms_server, "parms_sel2"),
                                                                       callModule(mod_parms_server, "parms_sel3"),
                                                                       callModule(mod_parms_server, "parms_sel4"))
                                                                 } else if (input$parms_controller == TRUE) {
                                                                     input$bias_factor
                                                                 },
                                                    alpha = input$alpha)
                               } else if (input$type == "misclass") {
                                   mod <- misclassification(mat,
                                                            type = input$misclass_type,
                                                            bias_parms = c(callModule(mod_parms_server, "parms_mis1"),
                                                                           callModule(mod_parms_server, "parms_mis2"),
                                                                           callModule(mod_parms_server, "parms_mis3"),
                                                                           callModule(mod_parms_server, "parms_mis4")),
                                                            alpha = input$alpha)
                               }
                           })

    ## Output of corrected data
    output$corr_data = renderTable({
                                       vals <- episensrout()
                                       vals$corr.data
                                   },
                                   rownames = TRUE
                                   )
    
    ## Output of observed measures of association
    output$obs_measures = renderTable({
                                          vals <- episensrout()
                                          vals$obs.measures
                                      },
                                      rownames = TRUE
                                      )

    ## Output of corrected measures of association
    output$adj_measures = renderTable({
                                          vals <- episensrout()
                                          vals$adj.measures
                                      },
                                      rownames = TRUE
                                      )

    ## Output of selection OR
    output$selbias_or = renderTable({
                                        vals <- episensrout()
                                        vals$selbias.or
                                    },
                                    colnames = FALSE)

    ## Automatically stop Shiny app when closing browser tab
    session$onSessionEnded(stopApp)

}
