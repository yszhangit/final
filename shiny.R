library(dplyr)
library(stringr)
library(shiny)
library(shinythemes)

#setwd('~/dev/R/final')
ngrams<-readRDS("grams_10pct_filter.RData")
debug_msg <- c()
debug_msg_max <- 10

# extract last 6 word
extract_text <- function(input) {
  if (length(input) == 0) {
    return(input)
  }
  # if there're punctuation, split and use words before last punct
  # [[:puntc:]] has one more char "'", becasue there are word like I'm, I'd,  you're, we have to keep it 
  input <- str_split(input,regex("[!\"?.,)(;:]"))[[1]] %>% tail(n=1)
  # convert to lowercase
  # split to list words, no need to deal with multi-space or formatting with gsub
  input <- str_split(tolower(input), boundary("word"))[[1]]
  len <- length(input)
  if (len > 6) {
    input <- input[(len-5):len] 
  }
  input
}

# find next word
# input is list, using input string as index to find ngrams$next_word
# the order of next_word is sorted in ngrams already
match_next <- function(input) {
  if (length(input) == 0 ) {
      return(c('',next_word=c()))
  }
  index <- str_flatten(input, collapse = " ")
  debug_msg <<- c(c(paste('try: ', index)), debug_msg)
  if (length(debug_msg) > debug_msg_max) {
    debug_msg <<- head(debug_msg, n=debug_msg_max)
  }
  res <- ngrams %>% filter(ind==index) %>% select(next_word,n)
  
  # when no match, first check if list is one word, 
  # if there are more than one word, recursive with removing first word, this is "back off"
  # if input is one word list, it's also end of recursive 
  if (dim(res)[1] == 0) {
    if (length(input) ==1) {
      return(c(index,next_word=c()))
    }else{
      return (match_next(input[-1]))
    }
  }else{
    return(c(index,res$next_word))
  }
  
}

ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("predict next word"),
  fluidRow(
    column(12,
           wellPanel(
             textInput("txt",
                       label="type here",
                       width="80%"
             )
           )
    )
  ),
  fluidRow(
    column(6, wellPanel( htmlOutput("prediction") )),
    column(6, wellPanel( htmlOutput("debug") ))
   ),
  fluidRow(
    h6("git repo: https://github.com/yszhangit/final")
  )
)

server <- function(input, output) {
  output$prediction <- renderText({
    if (length(input$txt) > 0 ) {
      res <- match_next(extract_text(input$txt))
      text <- paste("<ol><font size=3em>n-gram used \"",res[1],"\":")
      if (length(res) ==1 ) {
        text <- paste(text," no suggestions.</font></ol>")
        return(text)
      }
      res <- tail(res, n=-1)
      text <- paste(text, " [ ", length(res), " ] </font><li>")
      if (length(res) > 10) {
        res <- head(res, n=10)
      }
      text <- paste(text,str_flatten(res,collapse="</li><li>"),"</li></ol>")
      return(text)
    }
  })
  output$debug <- renderText({
    if (length(input$txt) > 0 ) {
      str_flatten(debug_msg, collapse = '<br />')
    }
  })
}

shinyApp(ui=ui, server=server)