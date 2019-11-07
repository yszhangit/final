# https://www.tidytextmining.com/tidytext.html
library(tidytext)
library(dplyr)
text <- c("Because I could not stop for Death -",
          "He kindly stopped for me -",
          "The Carriage held but just Ourselves -",
          "and Immortality")
text_df <- tibble(line = 1:4, text = text)
text_df
text_df %>% unnest_tokens(word, text) # "word" is the output column name, "text" is input column name of text_df

# get a book
library(janeaustenr)
library(stringr)
original_books <- austen_books() %>%
  group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",  # DIVCLC, roman number?
                                                 ignore_case = TRUE)))) %>%
  ungroup()

# tokenization
tidy_books <- original_books %>% unnest_tokens(word, text)
tidy_books

# remove stop words
data("stop_words")
tidy_books <- tidy_books %>% anti_join(stop_words)
tidy_books

# word fequence
tidy_books %>% count(word, sort=T)
# plot
library(ggplot2)
tidy_books %>% count(word, sort=T) %>%
  filter(n>600) %>%
  mutate(word=reorder(word, n)) %>% # sort column by "n"
  ggplot(aes(word,n)) + geom_col() + coord_flip()


# wordcloud
library(wordcloud)
tidy_books %>% anti_join(stop_words) %>% count(word) %>% with(wordcloud(word, n, max.words = 100))

# ---------------------
# chapt2 opinion mining/sentiment analysis
### uni-gram/sentiment
sentiments
# three types of lexicon
library(tidytext)
library(textdata)

# most english words are neutral
get_sentiments('nrc')   # categorized
get_sentiments('afinn') # from -5 to 5 scale of negative to positive
get_sentiments('bing')  # binary negative positive

# different expression of sentiments
# get_sentiments('nrc') %>% group_by(sentiment) %>% summarise(n())

# 
library(janeaustenr)
library(dplyr)
library(stringr)

# what's positive word count of book "Emma"
tidy_books <- austen_books() %>%
  group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = T)))) %>%
  ungroup() %>%
  unnest_tokens(word, text)

nrc_joy <- get_sentiments("nrc") %>% filter(sentiment == 'joy')

tidy_books %>% filter(book == "Emma") %>% inner_join(nrc_joy) %>% count(word, sort=T)

# postive/negative changing trend over each book
library(tidyr)
jane_austen_sentiment <- tidy_books %>%
  inner_join(get_sentiments('bing')) %>%
  count(book, index=linenumber %/% 80, sentiment) %>% # for each 80 lines, %/% is floor, count number of sentiment
  spread(sentiment, n, fill = 0) %>%                  # read  https://r4ds.had.co.nz/tidy-data.html explain gather and spread, spread basically turn given value of column into columns, in this case "postive" and "negative" are values of "sentiment", spread turn to columns
  mutate(sentiment = positive-negative) 

ggplot(jane_austen_sentiment, aes(index, sentiment, fill=book)) +
  geom_col(show.legend = F) +
  facet_wrap(~book, ncol=2, scales="free_x")

# beyond uni-gram, tokenize with sentence
tibble(text=prideprejudice) %>% unnest_tokens(sentence, text, token="sentences")
# not good at non-ASC

# ----------------------- 
# chapter 3, word frequency
# not interested atm
# tf-idf, intended to measure how important a word is to a document
# inverse document frequency (idf), which decreases the weight for commonly used words and increases the weight for words 
# that are not used very much in a collection of documents. 
# This can be combined with term frequency to calculate a term's tf-idf (the two quantities multiplied together)


# Zipf's law states that the frequency that a word appears is inversely proportional to its rank.

book_words <- austen_books() %>%
  unnest_tokens(word, text) %>%
  count(book, word, sort = TRUE) %>%
  ungroup()

total_words <- book_words %>% 
  group_by(book) %>% 
  summarize(total = sum(n))

book_words <- left_join(book_words, total_words)
book_words
# note tf_idf and idf are near zero for common words
book_words %>% bind_tf_idf(word, book, n )
# important word
book_words %>% bind_tf_idf(word, book, n ) %>% arrange(desc(tf_idf))

# ----------------------
# charpter 4, n-gram
# 2-gram tokenizing
austen_bigrams <- austen_books() %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

austen_bigrams
# lot of stop words, to remove, do it after tokenized
library(tidyr)
bigrams_separated <- austen_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)

# new bigram counts:
bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

bigram_counts

# 3-gram
austen_books() %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !word3 %in% stop_words$word) %>%
  count(word1, word2, word3, sort = TRUE)

# sentiment analysis

