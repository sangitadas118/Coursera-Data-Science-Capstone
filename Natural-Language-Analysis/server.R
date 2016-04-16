## Text of the books downloaded from:
## 
## Inside Starlizard: The story of Britain’s most successful gambler:
##    http://www.businessinsider.my/inside-story-star-lizard-tony-bloom-2016-2/?r=UK&IR=T
## Mugs and Millionaires: Inside the Murky World of Professional Football Gambling:
##    http://bleacherreport.com/articles/2200795-mugs-and-millionaires-inside-the-murky-world-of-professional-football-gambling
## Poker-Playing Soccer Boss Bloom Stakes Winnings on Charity Run:
##    http://www.bloomberg.com/news/articles/2015-04-08/poker-playing-soccer-boss-bloom-stakes-winnings-on-charity-run
##

suppressMessages(BBmisc::lib('DT', 'rCharts'))
#'@ options(RCHART_TEMPLATE = 'Rickshaw.html', RCHART_LIB = 'morris')

## Define server logic required to draw a histogram
shinyServer(function(input, output) {
  ## Define a reactive expression for the document term matrix
  terms <- reactive({
    ## Change when the "update" button is pressed...
    input$update
    ## ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$selection)
      })
    })
  })
  
  ## Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  output$txte <- renderText({
    paste0("<a href='", terms()$lnk, "'>", input$selection, "</a>")
  })
  
  output$article <- renderText({
    terms()$txt
  })
  
  output$wordplot <- renderPlot({
    mat <- terms()$mat
    mat <- mat[seq(ifelse(input$max>length(mat), length(mat), input$max)) & 
                 ifelse(input$freq>max(mat), max(mat), input$freq),]
    wordcloud_rep(names(mat), mat, scale=c(4,0.5),
                  min.freq = input$freq, max.words = input$max,
                  colors=brewer.pal(8, 'Dark2'))
  })
  
  ## https://rstudio.github.io/DT/shiny.html
  output$table <- renderDataTable({
    dat <- terms()$dat
    dat <- filter(dat[seq(ifelse(input$max>nrow(dat),nrow(dat),input$max)),], 
                Docs>=ifelse(input$freq>max(dat$Docs),max(dat$Docs),input$freq))
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
    dat <- terms()$dat
    dat <- filter(dat[seq(ifelse(input$max>nrow(dat),nrow(dat),input$max)),], 
                  Docs>=ifelse(input$freq>max(dat$Docs),max(dat$Docs),input$freq))
    ## http://stackoverflow.com/questions/26789478/rcharts-and-shiny-plot-does-not-show-up
    nPlot(Docs ~ Term, data = dat, type = 'multiBarChart')
    #'@ chart$nPlot(Docs ~ Term, data = dat, type = 'multiBarChart')
    #'@ chart$set(width = 600, height = '100%', slider = TRUE)
    #'@ return(chart)
  })
  
})
