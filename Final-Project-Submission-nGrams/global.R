if(!require('BBmisc')) suppressMessages(install.packages('BBmisc'))
if(!require('devtools')) suppressMessages(install_github('hadley/devtools'))
if(!require('memoise')) suppressMessages(devtools::install_github('hadley/memoise'))

suppressMessages(library('BBmisc'))
pkgs <<- c('doParallel', 'wordcloud', 'devtools', 'memoise', 'plyr', 'dplyr', 
           'magrittr', 'stringr', 'stringi', 'rvest', 'quanteda')
suppressAll(lib(pkgs))
rm(pkgs)

require('memoise', quietly=TRUE)   ##   since above lib() doesn't work on RStudioConnect.com but works locally.
require('plyr', quietly=TRUE)
require('dplyr', quietly=TRUE)
require('magrittr', quietly=TRUE)
require('stringr', quietly=TRUE)
require('stringi', quietly=TRUE)
require('quanteda', quietly=TRUE)

## Preparing the parallel cluster using the cores
doParallel::registerDoParallel(cores = 2)

## Load RDS files
de_DE <- suppressAll(readRDS('data/de_DE.rds'))
ru_RU <- suppressAll(readRDS('data/ru_RU.rds'))
en_US <- suppressAll(readRDS('data/en_US.rds'))
fi_FI <- suppressAll(readRDS('data/fi_FI.rds'))

# The list of valid books
languages <<- list('German' = 'german', 'Russian' = 'russian', 
                   'US English' = 'english', 'Finnish' = 'finnish')
books <<- list('blogs' = 'blogs', 'news' = 'news', 'twitter' = 'twitter')

## ==============================================================================
# Using "memoise" to automatically cache the results
selectData <- memoise(function(language, book) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if(!(language %in% languages)) stop('Unknown language')
  if(!(book %in% books)) stop('Unknown language')
  
  ## http://rpubs.com/Hsing-Yi/176027
  dat = switch(language,
               german = de_DE,
               russian = ru_RU,
               english = en_US,
               finnish = fi_FI)
  return(dat[[book]])
})