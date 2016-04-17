if(!require('BBmisc')) suppressMessages(install.packages('BBmisc'))
if(!require('devtools')) suppressMessages(install_github('hadley/devtools'))
if(!require('memoise')) suppressMessages(install_github('hadley/memoise'))

suppressMessages(library('BBmisc'))
pkgs <<- c('tm', 'wordcloud', 'devtools', 'memoise', 'plyr', 'dplyr', 'magrittr', 'stringr', 'rvest', 'googleVis')
suppressMessages(lib(pkgs))
rm(pkgs)


# The list of valid books
books <<- list('Inside Starlizard: The story of Britain’s most successful gambler' = 'Starlizard',
               'Mugs and Millionaires: Inside the Murky World of Professional Football Gambling' = 'Mugs',
               'Poker-Playing Soccer Boss Bloom Stakes Winnings on Charity Run' = 'Charity')

lnks <<- list('Inside Starlizard: The story of Britain’s most successful gambler' = 
               'http://www.businessinsider.my/inside-story-star-lizard-tony-bloom-2016-2/?r=UK&IR=T', 
             'Mugs and Millionaires: Inside the Murky World of Professional Football Gambling' = 
               'http://bleacherreport.com/articles/2200795-mugs-and-millionaires-inside-the-murky-world-of-professional-football-gambling', 
             'Poker-Playing Soccer Boss Bloom Stakes Winnings on Charity Run' = 
               'http://www.bloomberg.com/news/articles/2015-04-08/poker-playing-soccer-boss-bloom-stakes-winnings-on-charity-run')

# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(book) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if(!(book %in% books)){
    stop('Unknown book')
  }else{
    #http://www.r-bloggers.com/faster-files-in-r/
    #http://stackoverflow.com/questions/30445875/what-exactly-is-a-connection-in-r
    if(book==books[[1]]){
      lnk <- lnks[[1]]
      text <- read_html(lnk) %>% 
        html_node(xpath='/html/body/div[4]/div/div/div[2]/article') %>% html_text(trim=TRUE) %>% 
        str_replace_all('NOW WATCH((.*)\\n{1,}){1,}(.*$)', '')
    }else if(book==books[[2]]){
      lnk <- lnks[[2]]
      text <- read_html(lnk) %>% 
        html_node(xpath='//*[@id="article-slider"]/article') %>% html_text(trim=TRUE) %>% 
        str_replace_all('( ){1,}', ' ') #%>% str_replace_all('/[\n]+/', '\n')
      # http://stackoverflow.com/questions/700942/how-to-replace-multiple-newlines-in-a-row-with-one-newline-using-ruby
      #str_replace_all('/[\n]+/', '\n') doen't work 
    }else{
      lnk <- lnks[[3]]
      text <- read_html(lnk) %>% 
        html_nodes(xpath='//*[@id="content"]/div/div[1]/article/div[1]/div[1]/header|//*[@id="content"]/div/div[1]/article/div[1]/div[3]/section') %>% 
        html_text(trim=TRUE)
      text[1] %<>% str_replace_all('Share on.*Tony Bloom', 'Brighton & Hove Albion Chairman Tony Bloom.')
      text[2] %<>% str_replace_all('\\(function\\(global\\) \\{.*', '') %>% 
        str_replace_all('Share on.*Tony Bloom', 'Tony Bloom') %>% str_replace_all('\n\n\n Before.*', '')
      text <- paste0(text, collapse='\n\n')
    }
  }
  
  myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, content_transformer(tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, removeWords, c(stopwords('SMART'), 'thy', 'thou', 'thee', 'the', 'and', 'but'))
  
  myDTM = TermDocumentMatrix(myCorpus, control = list(minWordLength = 1))
  mat = as.matrix(myDTM) %>% na.omit
  mat = sort(rowSums(mat), decreasing = TRUE) %>% as.matrix(.)
  dat = data.frame(Term=row.names(mat), Docs=mat) %>% tbl_df
  
  return(list(txt=text, lnk=lnk, mat=mat, dat=dat))
})