setwd('~/dev/R/final')
# full news source 1M char, 257MB
# news <- readLines("./final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = T)
source <- readLines("./final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = T, n=10000)
source <- paste(readLines("./final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul = T, n=10000),source, sep="\n")
source <- paste(readLines("./final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul = T, n=10000),source, sep="\n")

library(tidytext)
library(dplyr)
library(tidyr)
gram2 <- tibble(text = source) %>% 
  unnest_tokens(grams, text, token="ngrams",n=2) %>% 
  count(grams, sort=T) %>% 
  filter(n>100) %>%
  separate(grams, c("ind","next"), sep=" ") 

gram3 <- tibble(text = source) %>% 
  unnest_tokens(grams, text, token="ngrams",n=3) %>% 
  count(grams, sort=T) %>% 
  separate(grams, c("a","b","next"), sep=" ")  %>%
  mutate(ind=paste(a,b, sep=" ")) %>%
  select("ind","next","n")

gram4 <- tibble(text = source) %>% 
  unnest_tokens(grams, text, token="ngrams",n=4) %>% 
  count(grams, sort=T) %>% 
  separate(grams, c("w1","w2","w3","next"),sep=" ") %>%
  mutate(ind=paste(w1,w2,w3, sep=" ")) %>% 
  select("ind","next","n")

gram5 <- tibble(text = source) %>% 
  unnest_tokens(grams, text, token="ngrams",n=5) %>% 
  count(grams, sort=T) %>% 
  separate(grams, c("w1","w2","w3","w4","next"),sep=" ") %>%
  mutate(ind=paste(w1,w2,w3,w4, sep=" ")) %>% 
  select("ind","next","n")

grams <- rbind(gram2, gram3, gram4, gram5)
saveRDS(grams, file="grams.Rdata")
