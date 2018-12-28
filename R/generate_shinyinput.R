#' @title A helper function that takes a model and generates the shiny UI elements for the analyze tab
#'
#' @description This function generates numeric shiny UI inputs for a supplied model.
#' This is a helper function called by the shiny app.
#' @param mbmodel a name of a file/function or a modelbuilder model structure
#' @param otherinputs a list of other inputs to include
#' @param output shiny output structure
#' @return No direct return. output structure is modified to contain text for display in a Shiny UI
#' @details This function is called by the Shiny app to produce the Shiny input UI elements.
#' If mbmodel is an object, it is assumed to be a mbmodel type and will be parsed to create the UI elements.
#' If mbmodel is a character, it is assumed to be the name of a function which will be parsed to create UI elements.
#' Non-numeric arguments of functions are removed.
#' @author Andreas Handel
#' @export

#not used in DSAIRM, might need to turn on again for modelbuilder
generate_shinyinput <- function(mbmodel, otherinputs, output)
{

    #function used below to wrap inputs into a inline-block style
    #found here
    #https://stackoverflow.com/questions/42778522/in-r-adding-multiple-rshiny-actionbutton-or-selectinput-widgets-to-one-row/42778604#42778604
    inlineElement <- function(..., style = ""){ shiny::div(style = sprintf("display:inline-block; %s", style), ...) }


#     #standard additional input elements for each model
#     standardinputs <- tagList(
#             numericInput("nreps", "Number of simulations", min = 1, max = 50, value = 1, step = 1),
#             selectInput("modeltype", "Model to run",c("ODE" = "ode", 'stochastic' = 'stochastic', 'discrete time' = 'discrete'), selected = 'ode'),
#             numericInput("rngseed", "Random number seed", min = 1, max = 1000, value = 123, step = 1),
#             selectInput("plotscale", "Log-scale for plot:",c("none" = "none", 'x-axis' = "x", 'y-axis' = "y", 'both axes' = "both"))
#         )

        #removeUI( selector = "div:has(> #analyzemodel)", immediate = TRUE  )

    ###########################################
    #create UI elements as input/output for shiny by parsing a function/R code
    #currently requires that function arguments are given in a vector, not a list like mbmodel functions do
    ###########################################
    if (class(mbmodel)=="character" )
    {
        ip = formals(mbmodel)
        #remove function arguments that are not numeric
        ip = ip[unlist(lapply(ip,is.numeric))]
        nvars = length(ip)  #number of variables/compartments in model
        modelargs = lapply(1:nvars, function(n) {
            inlineElement(numericInput(names(ip[n]), names(ip[n]), value = ip[n][[1]]))
                    })
    } #end UI creation for an underlying function

    #browser()


    ###########################################
    #create UI elements as input/output for shiny by parsing a modelbuilder object
    ###########################################
    if (class(mbmodel)=="list")
    {

        nvars = length(mbmodel$var)  #number of variables/compartments in model
        npars = length(mbmodel$par)  #number of parameters in model
        ntime = length(mbmodel$time)  #number of time variables in model

        #numeric input elements for all variable initial conditions
        allv = lapply(1:nvars, function(n) {
            inlineElement(numericInput(mbmodel$var[[n]]$varname,
                             paste0(mbmodel$var[[n]]$vartext,' (',mbmodel$var[[n]]$varname,')'),
                             value = mbmodel$var[[n]]$varval,
                             min = 0, step = mbmodel$var[[n]]$varval/100))
                    })

        allp = lapply(1:npars, function(n) {
            inlineElement(numericInput(
                    mbmodel$par[[n]]$parname,
                    paste0(mbmodel$par[[n]]$partext,' (',mbmodel$par[[n]]$parname,')'),
                    value = mbmodel$par[[n]]$parval,
                    min = 0, step = mbmodel$par[[n]]$parval/100))
                    })

        allt = lapply(1:ntime, function(n) {
            inlineElement(numericInput(
                    mbmodel$time[[n]]$timename,
                    paste0(mbmodel$time[[n]]$timetext,' (',mbmodel$time[[n]]$timename,')'),
                    value = mbmodel$time[[n]]$timeval,
                    min = 0, step = mbmodel$time[[n]]$timeval/100))
                    })
        modelargs = c(allv,allp,allt)
    } #end mbmodel object parsing

if (!is.null(otherinputs))
{
    otherargs = lapply(otherinputs,inlineElement)
}


#return structure
output$modelinputs <- renderUI({
    tagList(modelargs, otherargs)
}) #end renderuI

} #end overall function
