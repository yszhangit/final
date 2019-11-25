library(dplyr)
library(stringr)
library(shiny)
library(shinythemes)

ngrams<-readRDS("grams_01pct.RData")

# extract last 6 word
extract_text <- function(input) {
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
match_next <- function(input) {
  if (length(input) ==0 ) {
    return(c('',next_word=c()))
  }
  index <- str_flatten(input, collapse = " ")
  #cat('matching ', index, "\n")
  res <- ngrams %>% filter(ind==index) %>% select(next_word,n)
  
  # when no match, first check if list is one word, 
  # if there are more than one word, recursive with removing first word, this is "back off"
  # if input is one word list, return NA
  if (dim(res)[1] == 0) {
    if (length(input) ==1) {
      return(NA)
    }else{
      return (match_next(input[-1]))
    }
  }else{
    return(c(index,res))
  }
  
}

match_next(extract_text("nice I watched the whole "))
match_next(extract_text("hi there how are you"))
match_next(extract_text("you."))
match_next(extract_text("youuuu"))
match_next(extract_text("hi there, you're the most"))

