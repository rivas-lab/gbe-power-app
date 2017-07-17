library(shiny)

genes = as.character(read.table("data/shiny_genes.tsv", 
                                header=FALSE)$V1)

shinyUI(pageWithSidebar(
  headerPanel('PTV Association Power'),
  sidebarPanel(
    selectInput("gene", "Gene", choices=genes, selectize=TRUE, selected="PCSK9"),
    sliderInput("pD", "Disease prevalence", value=0.1, min=0, max=1, step=0.01),
    numericInput("RRAa", "Heterozygous relative risk", value=2, min=1),
    numericInput("nCase", "Number of cases", value=25000, min=0),
    numericInput("nControl", "Number of controls", value=25000, min=0),
    numericInput("alpha", "Type I error rate", value=2e-6, min=0, max=1),
    checkboxInput("unselected", label = "Unselected controls", value = FALSE)
  ),
  mainPanel(
    plotOutput('plot1')
  )
))