library(shiny)
library(GeneticsDesign)
library(ggplot2)
library(dplyr)

pops <- c("AFR", "AMR", "ASJ", "EAS", "FIN", "NFE", "SAS", "UKB")

af.gnomad = read.table("data/shiny_data.tsv", 
                       sep="\t", header=TRUE)#, row.names=1)#, quote="\"")
af.ukb = read.table("data/shiny_ukb.tsv", 
                    sep="\t", header=TRUE)#, row.names=1)#, quote="\"")

af.data = af.gnomad %>% left_join(af.ukb)
# For now, I will replaec NA with zero. In the future, I should probably make it
# so that nothing is displayed when there are NAs for a particular population.
af.data[is.na(af.data)] <- 0
rownames(af.data) <- af.data$gene_name
af.data$gene_name <- NULL
y.things <- paste("AF_bayes_", pops, sep="")
ymin.things <- paste("AF_bayes_ci_lower_", pops, sep="")
ymax.things <- paste("AF_bayes_ci_upper_", pops, sep="")

theme_set(theme_bw(base_size=18))
a <- colnames(af.data)[seq(1, dim(af.data)[2], 3)]
#xlabels <- as.factor(sapply(a, function(x) unlist(strsplit(x, split="_"))[3]))
xlabels <- pops

shinyServer(function(input, output, session) {
  
  afs <- reactive({af.data[input$gene, ]})
  ratio <- reactive({input$nControl / input$nCase})
  
  power.vals <- reactive({sapply(afs(), function(x) GPC.default(
    pA=x, pD=input$pD, RRAa=input$RRAa, RRAA=input$RRAa * 2, 
    Dprime=1, pB=x, nCase=input$nCase, ratio=ratio(), alpha=input$alpha, 
    unselected=input$unselected, quiet=TRUE)$power)
  })

  power.df <- reactive({data.frame(
    x = seq(1, length(power.vals()) / 3, 1),
    y = power.vals()[y.things],
    ymin = power.vals()[ymin.things],
    ymax = power.vals()[ymax.things],
    xlabels = xlabels
  )})

  output$plot1 <- renderPlot({
    ggplot(power.df(), aes(x = x,y = y)) + 
      geom_point(size=4) + 
      geom_errorbar(aes(ymin = ymin, ymax = ymax), width=0.25) + 
      xlab("Populations") + 
      ylab("Power") + 
      scale_x_continuous(breaks=seq(length(xlabels)), labels = power.df()$xlabels)
  })

})