#' @import shiny
#' @import shinythemes
#' @import rmarkdown
#' @import episensr
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
                 icon = icon("cog", lib = "glyphicon")),
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
