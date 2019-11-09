setwd('~/dev/R/final')

#tw<-readLines("./en_US.twitter.txt", encoding = "UTF-8", skipNul = T)
#blogs <- readLines("./en_US.blogs.txt", encoding = "UTF-8", skipNul = T)
news <- readLines("./final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = T, n=10000)

proc_text <- function(input) {
#  input <- replace_number(input, remove=T)
  words <- tibble(text = input) %>% unnest_tokens(word, text)
  words <- words %>% anti_join(stop_words, by="word")
  words <- gsub("\\d+","",words)
  word_cnt <- words %>% count(word, sort=T)
  word_cnt
}
# start with .1% for testing, 5% is 600M vcropus
library(ggplot2)
library(tidytext)
#library(textclean)
library(dplyr)
#library(stopwords)
library(wordcloud)


# not needed, tokenizing doesnt make any different, or textclean function doesnt work at all
"
pct = .1
sample.tw <- sample(tw, length(tw)*pct)
sample.blogs <- sample(blogs, length(blogs)*pct)
sample.news <- sample(news, length(news)*pct)
sample.all <- c(sample.tw, sample.blogs, sample.news)
#sample_all <- unlist(strsplit(sample.all, split=", "))
sample.all <- replace_non_ascii(sample.all)   # slow
#sample.all <- replace_emoticon(sample.all)
#sample.all <- replace_emoji(sample.all)
sample.all <- replace_contraction(sample.all)
sample.all <- replace_time(sample.all)
sample.all <- replace_date(sample.all)
#sample.all <- replace_escape(sample.all)
sample.all <- replace_html(sample.all)
sample.all <- replace_url(sample.all)
sample.all <- replace_tag(sample.all)
sample.all <- replace_white(sample.all) # escape
sample.all <- replace_number(sample.all, remove=T)
check_text(sample.all, n=1)
"

#library(tm)
# set windows env for rJava
# https://support.microsoft.com/en-us/help/3103813/qa-when-i-try-to-load-the-rjava-package-using-the-library-command-i-ge
#library(RWeka)

#cleaned <-VCorpus(VectorSource(sample.all))
#cleaned <- tm_map(cleaned, PlainTextDocument)
#cleaned <- tm_map(cleaned, stripWhitespace)
#cleaned <- tm_map(cleaned, removePunctuation)
#cleaned <- tm_map(cleaned, removeNumbers)
#cleaned <- tm_map(cleaned, removeWords, c("a",",and","the","an"))
#cleaned <- tm_map(cleaned, content_transformer(tolower))

#library(slam)

#library(dplyr)
#words  <-  tibble(text = cleaned) %>% unnest_tokens(word, text)
#words  <-  tibble(text = sample.all) %>% unnest_tokens(word, text)
#words  <-  tibble(text = tw) %>% unnest_tokens(word, text)
#words  <-  tibble(text = news) %>% unnest_tokens(word, text)
#words  <-  tibble(text = tw) %>% unnest_tokens(word, text)
#words <- words %>% anti_join(stop_words)
# count
#word_cnt <- words %>% count(word, sort=T)

word_cnt <- proc_text(news)

# count of 10th most freq word 
word_cnt %>% filter(n >= as.integer(word_cnt[20,2]) ) %>%
  mutate(word=reorder(word,n)) %>%
  ggplot(aes(word,n)) + geom_col()+ coord_flip()

# freq of freq
word_cnt %>%  ggplot(aes(n)) +  geom_histogram(bins = 20) +  
  scale_x_continuous(trans = "log10", breaks = c(0,1,3,4,5,10,30,100)) +  
  xlab("word freq log10")

# cloud
word_cnt %>% with(wordcloud(word, n, random.order=F, max.words = 50, colors=brewer.pal(6,"Dark2")))

