#' @import shiny
#' @import shinythemes
#' @import rmarkdown
#' @import rhandsontable
#' @import shinyWidgets
#' @import shinyjs
#' @import episensr
#misclass_ex = data.frame(Exposed = c(215, 668), Unexposed = c(1449, 4296),
#                         row.names = c("Cases", "Noncases"))

app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here
    navbarPage(
        theme = shinytheme("united"),
        "episensr: Basic Sensitivity Analysis of Epidemiological Results",
        tabPanel("Main",
                 icon = icon("home", lib = "glyphicon"),
                 sidebarPanel(
                     radioButtons("type", strong("Type of bias analysis:"),
                                  list("Selection bias" = "selection",
                                       "Misclassification bias" = "misclass",
                                       "Probabilistic sensitivity analysis" = "probsens")
                                  )
                 ),
                 mainPanel(column(10, uiOutput("bias_choice")))
                 ),
        tabPanel("Analysis",
                 icon = icon("cog", lib = "glyphicon"),
                 sidebarPanel(shinyjs::useShinyjs(),
                              id = "side-panel",
                              conditionalPanel(
                                  condition = "input.type == 'selection'",
                                  h3("Selection bias")
                              ),
                              conditionalPanel(
                                  condition = "input.type == 'misclass'",
                                  h3("Misclassification bias")
                              ),
                              h4("Observed data:"),
                              rHandsontableOutput('two_by_two'),
                              br(),
                              conditionalPanel(
                                  condition = "input.type == 'selection'",
                                  prettyCheckbox(
                                      inputId = "parms_controller",
                                      label = "Providing Selection-bias factor instead of Selection probabilities",
                                      value = FALSE,
                                      status = "primary",
                                      icon = icon("check"),
                                      animation = "smooth"),
                                  conditionalPanel(
                                      condition = "input.parms_controller == 0",
                                      mod_parms_ui("parms_sel1",
                                                   "Selection probability among cases exposed:", 0.94),
                                      mod_parms_ui("parms_sel2",
                                                   "Selection probability among cases unexposed:", 0.85),
                                      mod_parms_ui("parms_sel3",
                                                   "Selection probability among noncases exposed:", 0.64),
                                      mod_parms_ui("parms_sel4",
                                                   "Selection probability among noncases unexposed:", 0.25)
                                  ),
                                  conditionalPanel(
                                      condition = "input.parms_controller == 1",
                                      ## Selection-bias factor
                                      sliderInput("bias_factor",
                                                  "Selection-bias factor:",
                                                  value = 0.43,
                                                  min = 0,
                                                  max = 1,
                                                  width = "600px")                       
                                  )
                              ),
                              conditionalPanel(
                                  condition = "input.type == 'misclass'",
                                  radioGroupButtons(
                                      inputId = "misclass_type",
                                      label = "Misclassification of:",
                                      choices = c("exposure",
                                                  "outcome"),
                                      selected = "exposure",
                                      status = "primary",
                                      justified = TRUE
                                  ),
                                  mod_parms_ui("parms_mis1",
                                               "Sensitivity of exposure (or outcome) classification among those with the outcome (or exposure):", 0.78),
                                  mod_parms_ui("parms_mis2",
                                               "Sensitivity of exposure (or outcome) classification among those without the outcome (or exposure):", 0.78),
                                  mod_parms_ui("parms_mis3",
                                               "Specificity of exposure (or outcome) classification among those with the outcome (or exposure):", 0.99),
                                  mod_parms_ui("parms_mis4",
                                               "Specificity of exposure (or outcome) classification among those without the outcome (or exposure):", 0.99)
                              ),
                              ## Alpha level
                              sliderInput("alpha",
                                          HTML("&alpha;-level:"),
                                          value = 0.05,
                                          min = 0.01,
                                          max = 0.2,
                                          width = "600px"),
                              actionBttn(
                                  inputId = "reset_input",
                                  label = "Back to example",
                                  style = "material-flat",
                                  color = "primary",
                                  icon = icon("repeat", lib = "glyphicon"),
                                  size = "sm"
                              )
                              ),
                 mainPanel(
                     fluidRow(
                         column(width = 4,
                                br(), br(), br(),
                                h4("Corrected data:"),
                                tableOutput(outputId = "corr_data")
                                ),
                         column(width = 8,
                                br(), br(), br(),
                                h4("Observed measures of association:"),
                                tableOutput(outputId = "obs_measures"),
                                h4("Corrected measures of association:"),
                                br(),
                                tableOutput(outputId = "adj_measures"),
                                conditionalPanel(
                                    condition = "input.type == 'selection'",
                                    h5("Selection bias odds ratio based on the bias parameters chosen:"),
                                    tableOutput(outputId = "selbias_or")
                                )
                                )
                     )
                 )
                 ),
        navbarMenu("About episensr",
                   icon = icon("bullseye", lib = "font-awesome"),
                   tabPanel("About",
                            icon = icon("address-card-o", lib = "font-awesome"),
                            column(1),
                            column(5, rep_br(3),
                                   p("Quantitative bias analysis allows to estimate nonrandom errors in epidemiologic studies, assessing the magnitude and direction of biases, and quantifying their uncertainties. Every study has some random error due to its limited sample size, and is susceptible to systematic errors as well, from selection bias to the presence of (un)known confounders or information bias (measurement error, including misclassification). Bias analysis methods were compiled by Lash et al. in their book", enurl("https://www.springer.com/us/book/9780387879604", "Applying Quantitative Bias Analysis to Epidemiologic Data."), "This Shiny app implements two bias analyses, selection and misclassification biases. More can be found in the", code("episensr"), "package available for download on", enurl("https://CRAN.R-project.org/package=episensr", "R CRAN"), "."), rep_br(3), includeMarkdown("inst/app/www/functions.md")),
                            column(5, rep_br(3),
                                   wellPanel("Please report bugs at", enurl("https://github.com/dhaine/episensr.app/issues", "https://github.com/dhaine/episensr.app/issues"), rep_br(2), "Shiny app by", enurl("https://www.denishaine.ca", "Denis Haine"), rep_br(2), "episensr version:", verbatimTextOutput("versioning", placeholder = TRUE))),
                            column(1)
                            )
                   )
    )
  )
}

#' @import shiny
golem_add_external_resources <- function(){
  
  addResourcePath(
    'www', system.file('app/www', package = 'episensr.app')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon()
    # Add here all the external resources
    # If you have a custom.css in the inst/app/www
    # Or for example, you can add shinyalert::useShinyalert() here
    #tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
  )
}
