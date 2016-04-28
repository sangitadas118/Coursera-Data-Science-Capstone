suppressMessages(BBmisc::lib(c('shiny', 'DT', 'rCharts')))
require('shiny', quietly=TRUE)
require('shinyjs', quietly = TRUE)
require('rCharts', quietly=TRUE) ## Unable find showOutput function without library()/require() 
require('DT', quietly=TRUE)      ##   since above lib() doesn't work on RStudioConnect.com but works locally.

# Define UI for application that draws a histogram
ui <- shinyUI(
  fluidPage(
    # Application title
    titlePanel('Coursera Data Science Capstone - Final Project Submission', 
               #tags$li(class = 'dropdown',
               tags$a(href='http://rpubs.com/englianhu/ryoeng', target='_blank', 
                      tags$img(height = '20px', alt='Ryo Eng', #align='right', 
                               src='https://avatars0.githubusercontent.com/u/7227582?v=3&s=460')
                      #        )
               )),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(
        selectInput('selection1', 'Choose a language:', choices = languages), 
        selectInput('selection2', 'Choose a book:', choices = books),
        actionButton('change', 'Change'), 
        hr(), 
        sliderInput('freq', 'Minimum Frequency:', min = 1,  max = 50, value = 15),
        sliderInput('max', 'Maximum Number of Words:', min = 1,  max = 300,  value = 100)
        )
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          tabPanel('Article', verbatimTextOutput('article')),
          tabPanel('WordCloud', plotOutput('wordplot')), 
          tabPanel('Table', DT::dataTableOutput('table')), 
          tabPanel('Histogram', showOutput('histplot', 'nvd3')), 
          tabPanel('Conclusion', 
                   h4('Changed and Different with RMarkdown Report:'),
                   p("1. I've using quanteda package inside this shiny app which is more eficient to handle text mining, and ngram analysis."),
                   p("2. I've saved objects as rds format files since it is more efficient in both capacity saving and also reading speed. You are feel free to source('function/saveData.R') to save the files."),
                   p("3. There has a lot of coding I need to review during spare time.")),
          tabPanel('Reference', 
                   h4('Reference:'),
                   p('1. ', HTML("<a href='http://rpubs.com/davidldenton/dsc_milestone'>Data Science Capstone - Milestone Report</a>")),
                   p('2. ', HTML("<a href='http://rpubs.com/Hsing-Yi/176027'>Final_W2</a>"),
                   tags$a(href='http://rpubs.com/englianhu/ryoeng', target='_blank', 
                          tags$img(height = '20px', alt='hot', #align='right', 
                                   src='http://www.clipartbest.com/cliparts/niB/z9r/niBz9roiA.jpeg'))),
                   p('3. ', HTML("<a href='http://rpubs.com/plalithas/AutoTextMilestoneReport'>Auto Text Suggestion App</a>")),
                   p('4. ', HTML("<a href='http://rstudio-pubs-static.s3.amazonaws.com/39014_76f8487a8fb84ed7849e96846847c295.html'>Text Prediction With R</a>")),
                   br(),
                   h4('Here are few data visulaization samples where you can write yours :'),
                   p('1. ', HTML("<a href='http://rcharts.readthedocs.org/en/latest/intro/create.html'>rCharts Web-based Manual</a>"),
                     tags$a(href='http://rpubs.com/englianhu/ryoeng', target='_blank', 
                            tags$img(height = '20px', alt='hot', #align='right', 
                                     src='http://www.clipartbest.com/cliparts/niB/z9r/niBz9roiA.jpeg'))),
                   p('2. ', HTML("<a href='http://timelyportfolio.github.io/rCharts_nvd3_systematic/cluster_weights.html'>Interactive Analysis of Systematic Investor</a>"))
          ), 
          tabPanel('Appendices', 
                   h4('Documenting File Creation:'),
                   p('1. File creation date: 2016-04-27'),
                   p('2. File latest updated date:', span(id = 'time', date()), 
                     a(id = 'update', 'Update', href = '#')),
                   p('3.', verbatimTextOutput('Rver')), 
                   p('4.', HTML("<a href='https://github.com/rstudio/shiny'>shiny</a>"), 'package:', verbatimTextOutput('shinyVer')), 
                   p('5. File version: 1.0.0'),
                   p('6. Author Profile:', HTML("<a href='https://beta.rstudioconnect.com/englianhu/ryo-eng/'>®γσ, Eng Lian Hu</a>")), 
                   p('7. GitHub:', HTML("<a href='https://github.com/englianhu/Coursera-Data-Science-Capstone'>Source Code</a>")),
                   br(),
                   h4('You can refer to my tutorial below:'),
                   p('1. Tutorial:', HTML("<a href='https://github.com/scibrokes/setup-rstudio-server'>安装 ®StudioとShiny服务器</a>"))
                   )
          )
        )
      )
    )
  )
