setwd('~/dev/R/final')

library(tidytext)
library(dplyr)
library(tidyr)

# full news source 1M char, 257MB
#source <- readLines("./final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = T, n=100000)
source <- readLines("./final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = T)
source <- paste(readLines("./final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul = T), source, sep="\n")
source <- paste(readLines("./final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul = T), source, sep="\n")
#source <- src
src <- tibble(text = source)
#source <- sample_frac(source, 0.05) # 360M
#source <- sample_frac(source, 0.01) # 80M, shinyapp.io run out of memory 
#source <- sample_frac(source, 0.001) # 9M, too few result
src <- sample_frac(src, 0.1)

gram2 <-  src %>% 
  unnest_tokens(grams, text, token="ngrams",n=2) %>% 
  count(grams, sort=T) %>% 
  filter(n>5) %>%
  separate(grams, c("ind","next_word"), sep=" ") 

gram3 <- src %>%
  unnest_tokens(grams, text, token="ngrams",n=3) %>% 
  count(grams, sort=T) %>% 
  filter(n>2) %>%
  separate(grams, c("a","b","next_word"), sep=" ")  %>%
  mutate(ind=paste(a,b, sep=" ")) %>%
  select("ind","next_word","n")

gram4 <- src %>% 
  unnest_tokens(grams, text, token="ngrams",n=4) %>% 
  count(grams, sort=T) %>% 
  filter(n>1) %>%
  separate(grams, c("w1","w2","w3","next_word"),sep=" ") %>%
  mutate(ind=paste(w1,w2,w3, sep=" ")) %>% 
  select("ind","next_word","n")

gram5 <- src %>% 
  unnest_tokens(grams, text, token="ngrams",n=5) %>% 
  count(grams, sort=T) %>% 
  filter(n>1) %>%
  separate(grams, c("w1","w2","w3","w4","next_word"),sep=" ") %>%
  mutate(ind=paste(w1,w2,w3,w4, sep=" ")) %>% 
  select("ind","next_word","n")

gram6 <- src %>% 
  unnest_tokens(grams, text, token="ngrams",n=6) %>% 
  count(grams, sort=T) %>% 
  filter(n>1) %>%
  separate(grams, c("w1","w2","w3","w4","w5","next_word"),sep=" ") %>%
  mutate(ind=paste(w1,w2,w3,w4,w5, sep=" ")) %>% 
  select("ind","next_word","n")

ngrams <- rbind(gram2, gram3, gram4, gram5, gram6)
#saveRDS(ngrams, file="grams_1pct.RData")
#saveRDS(ngrams, file="grams_01pct.RData")
#saveRDS(ngrams, file="grams_1pct_filter.RData")
#saveRDS(ngrams, file="grams_5pct_filter.RData")
saveRDS(ngrams, file="grams_10pct_filter.RData")
#saveRDS(ngrams, file="grams_5pct.RData")

#ngrams<-readRDS('grams.RData')
