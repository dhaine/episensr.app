#' @import shiny
app_server <- function(input, output,session) {
    # List the first level callModules here
    ## version
    output$versioning <- renderPrint(packageVersion("episensr"))

    output$bias_choice <- renderUI({
                                       bias_file <- switch(input$type,
                                                           selection = "inst/app/www/selection_bias.md",
                                                           misclass = "inst/app/www/misclassification.md",
                                                           probsens = "inst/app/www/probsens.md"
                                                           )
                                       includeMarkdown(bias_file)
                                   })

    DF = reactive({
                      if(input$type == "selection") {
                          data.frame(Exposed = c(136, 297), Unexposed = c(107, 165),
                                     row.names = c("Cases", "Noncases"))
                      } else if(input$type == "misclass") {
                          data.frame(Exposed = c(215, 668), Unexposed = c(1449, 4296),
                                     row.names = c("Cases", "Noncases"))
                      } else if(input$type == "probsens") {
                          data.frame(Exposed = c(45, 257), Unexposed = c(94, 945),
                                     row.names = c("Cases", "Noncases"))
                      }
                  })

    output$two_by_two = renderRHandsontable({
                                                input$reset_input # trigger rendering on reset
                                                rhandsontable(DF(),
                                                              rowHeaderWidth = 200,
                                                              width = 400,
                                                              stretchH = "all")
                                            })

    episensrout = reactive({
                               mat <- as.matrix(hot_to_r(req({input$two_by_two})))
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
                               } else if (input$type == "probsens") {
                                   mod <- probsens(mat,
                                                   type = input$probsens_type,
                                                   reps = 20000,
                                                   seca.parms = list("trapezoidal", c(.75, .85, .95, 1)),
                                                   spca.parms = list("trapezoidal", c(.75, .85, .95, 1)))
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

    observeEvent(input$reset_input, {
                     shinyjs::reset("side-panel")
                 })
    
    ## Automatically stop Shiny app when closing browser tab
    session$onSessionEnded(stopApp)

}
