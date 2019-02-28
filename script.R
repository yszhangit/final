tw<-readLines("./en_US.twitter.txt", encoding = "UTF-8", skipNul = T)
blogs <- readLines("./en_US.blogs.txt", encoding = "UTF-8", skipNul = T)
news <- readLines("./en_US.news.txt", encoding = "UTF-8", skipNul = T)

# start with .1% for testing, 5% is 600M vcropus
library(textclean)
library(dplyr)
pct = 0.001
sample.tw <- sample(tw, length(tw)*pct)
sample.blogs <- sample(blogs, length(blogs)*pct)
sample.news <- sample(news, length(news)*pct)
sample.all <- c(sample.tw, sample.blogs, sample.news)
sample_all <- unlist(strsplit(sample.all, split=", "))
sample.all <- replace_non_ascii(sample.all)
sample.all <- replace_emoticon(sample.all)
sample.all <- replace_emoji(sample.all)
sample.all <- replace_contraction(sample.all)
sample.all <- replace_time(sample.all)
sample.all <- replace_date(sample.all)
sample.all <- replace_escape(sample.all)
sample.all <- replace_html(sample.all)
sample.all <- replace_url(sample.all)
sample.all <- replace_tag(sample.all)
sample.all <- replace_white(sample.all) # escape
check_text(sample.all, n=1)
library(tm)
# set windows env for rJava
# https://support.microsoft.com/en-us/help/3103813/qa-when-i-try-to-load-the-rjava-package-using-the-library-command-i-ge
library(RWeka)

cleaned <-VCorpus(VectorSource(sample.all))
#cleaned <- tm_map(cleaned, PlainTextDocument)
#cleaned <- tm_map(cleaned, stripWhitespace)
#cleaned <- tm_map(cleaned, removePunctuation)
#cleaned <- tm_map(cleaned, removeNumbers)
#cleaned <- tm_map(cleaned, removeWords, c("a",",and","the","an"))
#cleaned <- tm_map(cleaned, content_transformer(tolower))

library(slam)
