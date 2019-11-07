tw<-readLines("./en_US.twitter.txt", encoding = "UTF-8", skipNul = T)
blogs <- readLines("./en_US.blogs.txt", encoding = "UTF-8", skipNul = T)
news <- readLines("./en_US.news.txt", encoding = "UTF-8", skipNul = T)

# start with .1% for testing, 5% is 600M vcropus
library(textclean)
library(dplyr)
pct = 0.01
sample.tw <- sample(tw, length(tw)*pct)
sample.blogs <- sample(blogs, length(blogs)*pct)
sample.news <- sample(news, length(news)*pct)
sample.all <- c(sample.tw, sample.blogs, sample.news)
#sample_all <- unlist(strsplit(sample.all, split=", "))
sample.all <- replace_non_ascii(sample.all)
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
library(tm)
# set windows env for rJava
# https://support.microsoft.com/en-us/help/3103813/qa-when-i-try-to-load-the-rjava-package-using-the-library-command-i-ge
library(RWeka)

cleaned <-VCorpus(VectorSource(sample.all))
cleaned <- tm_map(cleaned, PlainTextDocument)
cleaned <- tm_map(cleaned, stripWhitespace)
cleaned <- tm_map(cleaned, removePunctuation)
cleaned <- tm_map(cleaned, removeNumbers)
cleaned <- tm_map(cleaned, removeWords, c("a",",and","the","an"))
cleaned <- tm_map(cleaned, content_transformer(tolower))

library(slam)

library(tidytext)
library(dplyr)
#words  <-  tibble(text = cleaned) %>% unnest_tokens(word, text)
words  <-  tibble(text = sample.all) %>% unnest_tokens(word, text)
library(stopwords)
words <- words %>% anti_join(stop_words)
# count
word_cnt <- words %>% count(word, sort=T)
# plotting
library(ggplot2)
word_cnt %>% filter(n>1000) %>%
  mutate(word=reorder(word,n)) %>%
  ggplot(aes(word,n)) + geom_col()+ coord_flip()
# cloud
library(wordcloud)
word_cnt %>% with(wordcloud(word,n,max.words = 80))
