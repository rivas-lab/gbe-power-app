library(shiny)
library(GeneticsDesign)
library(ggplot2)
library(dplyr)
library(reshape2)

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

af.data.small = head(af.data, 100)

theme_set(theme_bw(base_size=18))
a <- colnames(af.data)[seq(1, dim(af.data)[2], 3)]
#xlabels <- as.factor(sapply(a, function(x) unlist(strsplit(x, split="_"))[3]))
xlabels <- pops

# I can add support for protective here.
gpc.wrapper <- function(pA, pD, RRAa, nCase, nControl, alpha, unselected) {
  if (pA == 0) {return(0)}
  else {
    ratio <- nControl / nCase
    return(GPC.default(pA=pA, pD=pD, RRAa=RRAa, RRAA=RRAa * 2, Dprime=1, 
                       pB=pA, nCase=nCase, ratio=ratio, alpha=alpha,
                       unselected=unselected, quiet=TRUE)$power)
  }
}

pops.power.summary <- function(df) {
  out <- colSums(df[,y.things] > 0.8)
  out <- data.frame("Population"=pops, "Number genes > 0.8 power"=out, check.names=FALSE)
  return(out)
}

shinyServer(function(input, output, session) {
  
  afs <- reactive({af.data[input$gene, ]})
  
  power.summary <- reactive({pops.power.summary(
    sapply(y.things, function(y) sapply(
      af.data[, y],
      function(x) gpc.wrapper(pA=x, pD=input$pD, RRAa=input$RRAa,
        nCase=input$nCase, nControl=input$nControl, alpha=input$alpha,
        unselected=input$unselected)
      )
      ))
  })
  
  power.vals <- reactive({sapply(afs(), function(x) gpc.wrapper(
    pA=x, pD=input$pD, RRAa=input$RRAa, nCase=input$nCase, nControl=input$nControl,
    alpha=input$alpha,unselected=input$unselected))
  })

  power.df <- reactive({data.frame(
    x = seq(1, length(power.vals()) / 3, 1),
    y = power.vals()[y.things],
    ymin = power.vals()[ymin.things],
    ymax = power.vals()[ymax.things],
    xlabels = xlabels,
    caf = as.vector(t(afs()[y.things]))
  )})
  
  display.df <- reactive({data.frame(
    Population = power.df()$xlabels,
    Power = power.df()$y,
    "Power CI Low" = power.df()$ymin,
    "Power CI High" = power.df()$ymax,
    "Composite Allele Frequency" = power.df()$caf
    )
  })

  output$plot.gene <- renderPlot({
    ggplot(power.df(), aes(x = x,y = y)) + 
      geom_point(size=4) + 
      geom_errorbar(aes(ymin = ymin, ymax = ymax), width=0.25) + 
      xlab("Populations") + 
      ylab("Power") + 
    coord_cartesian(ylim = c(-0.01, 1.01)) + 
      scale_x_continuous(breaks=seq(length(xlabels)), labels = power.df()$xlabels)
  })
  
  # output$plot.summary <- renderPlot({
  #   ggplot(NULL, aes(af.data.small$AF_bayes_AFR)) + 
  #     geom_histogram(aes(y=cumsum(..count..)))
  # })
  # output$plot.summary <- renderPlot({
  #   ggplot(power.summary(), aes(value, colour = "Population")) + 
  #     stat_bin(aes(y=cumsum(..count..)), geom="line")
  # })
  # ggplot(NULL,aes(res[,"AF_bayes_AFR"]))+stat_bin(aes(y=cumsum(..count..)),geom="line",color="green")
  # facet_grid(series ~ Population)
  
  output$table.gene <- renderTable({display.df()}, digits=-2)
  output$table.summary <- renderTable({power.summary()})

})