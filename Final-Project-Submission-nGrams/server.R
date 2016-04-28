suppressMessages(require(BBmisc, quietly = TRUE))
suppressAll(require('shiny', quietly = TRUE))
suppressAll(require('shinyjs', quietly = TRUE))
suppressAll(require('rCharts', quietly = TRUE)) ## Unable find showOutput function without library()/require() 
suppressAll(require('DT', quietly = TRUE))      ##   since above lib() doesn't work on RStudioConnect.com but works locally.
#'@ options(RCHART_TEMPLATE = 'Rickshaw.html', RCHART_LIB = 'morris')

## Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  onclick('update', html('time', date()))
  
  ## Define a reactive expression for the document term matrix
  terms <- reactive({
    ## Change when the "change" button is pressed...
    input$change
    ## ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        selectData(language = input$selection1, book = input$selection2)
      })
    })
  })
  
  ## Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  output$Rver <- renderText({
    print(R.version.string)
  })
  
  output$shinyVer <- renderText({
    packageVersion('shiny')
  })
  
  output$article <- renderText({
    terms()$txt
  })
  
  #'@ output$tabSummary <- renderDataTable({
  #'@   suppressAll(library('stringi'))
  #'@   data.frame(File = names(smp), t(sapply(smp, stri_stats_general))) %>% tbl_df %>% kable
  #'@ })
  
  output$wordplot <- renderPlot({
    mat <- terms()$mydfm
    mat <- mat[seq(ifelse(input$max > length(mat), length(mat), input$max)) & 
                 ifelse(input$freq > max(mat), max(mat), input$freq), ]
    wordcloud_rep(names(mat), mat, scale = c(4,0.5),
                  min.freq = input$freq, max.words = input$max,
                  colors = brewer.pal(8, 'Dark2'))
  })
  
  ## https://rstudio.github.io/DT/shiny.html
  output$table <- renderDataTable({
    dat <- terms()$corpUS
    dat <- filter(dat[seq(ifelse(input$max > nrow(dat), nrow(dat), input$max)), ], 
                  Docs >= ifelse(input$freq > max(dat$Docs), max(dat$Docs), input$freq))
    DT::datatable(dat, 
                  caption="Table : Number of words",
                  extensions = list("ColReorder"=NULL, "ColVis"=NULL, "TableTools"=NULL
                                    #, "FixedColumns"=list(leftColumns=2)
                  ), 
                  options = list(autoWidth=TRUE,
                                 oColReorder=list(realtime=TRUE), #oColVis=list(exclude=c(0, 1), activate='mouseover'),
                                 oTableTools=list(
                                   sSwfPath="//cdnjs.cloudflare.com/ajax/libs/datatables-tabletools/2.1.5/swf/copy_csv_xls.swf",
                                   aButtons=list("copy", "print",
                                                 list(sExtends="collection",
                                                      sButtonText="Save",
                                                      aButtons=c("csv","xls")))),
                                 dom='CRTrilftp', scrollX=TRUE, scrollCollapse=TRUE,
                                 colVis=list(exclude=c(0), activate='mouseover')))
  })
  
  ## make the rickshaw rChart
  ## http://rcharts.io/gallery/
  ## http://timelyportfolio.github.io/rCharts_rickshaw_gettingstarted/
  output$histplot <- renderChart2({
    #'@ chart <- Rickshaw$new()
    dat <- terms()$corpUS
    dat <- filter(dat[seq(ifelse(input$max > nrow(dat), nrow(dat), input$max)), ], 
                  Docs >= ifelse(input$freq > max(dat$Docs), max(dat$Docs), input$freq))
    ## http://stackoverflow.com/questions/26789478/rcharts-and-shiny-plot-does-not-show-up
    nPlot(Docs ~ Term, data = dat, type = 'multiBarChart')
    #'@ chart$nPlot(Docs ~ Term, data = dat, type = 'multiBarChart')
    #'@ chart$set(width = 600, height = '100%', slider = TRUE)
    #'@ return(chart)
  })
  
})
