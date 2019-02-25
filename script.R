tw<-readLines("./final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul = T)
blogs <- readLines("./final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul = T)
news <- readLines("./final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = T)

# start with 1%, 5% is 600M vcropus
pct = 0.001
sample.tw <- sample(tw, length(tw)*pct)
sample.blogs <- sample(blogs, length(blogs)*pct)
sample.news <- sample(news, length(news)*pct)
sample.all <- c(sample.tw, sample.blogs, sample.news)
sample_all <- unlist(strsplit(sample.all, split=", "))
library(textclean)
sample.all <- replace_non_ascii(sample.all)
library(tm)
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
