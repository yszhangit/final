# https://www.tidytextmining.com/tidytext.html
library(tidytext)
library(dplyr)
text <- c("Because I could not stop for Death -",
          "He kindly stopped for me -",
          "The Carriage held but just Ourselves -",
          "and Immortality")
text_df <- tibble(line = 1:4, text = text)
text_df
text_df %>% unnest_tokens(word, text)

# get a book
library(janeaustenr)
library(stringr)
original_books <- austen_books() %>%
  group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = TRUE)))) %>%
  ungroup()

# tokenization
tidy_books <- original_books %>% unnest_tokens(word, text)
tidy_books

# remove stop words
data("stop_words")
tidy_books <- tidy_books %>% anti_join(stop_words)

# word fequence
tidy_books %>% count(word, sort=T)

# wordcloud
library(wordcloud)
tidy_books %>% anti_join(stop_words) %>% count(word) %>% with(wordcloud(word, n, max.words = 100))

### uni-gram/sentiment
sentiments
# three types of lexicon

get_sentiments('afinn')
get_sentiments('bing')
get_sentiments('nrc')
# different expression of sentiments
get_sentiments('nrc') %>% group_by(sentiment) %>% summarise(n())

# multi word sentiment
bingnegative <- get_sentiments("bing") %>% 
  filter(sentiment == "negative")

wordcounts <- tidy_books %>%
  group_by(book, chapter) %>%
  summarize(words = n())

tidy_books %>%
  semi_join(bingnegative) %>%
  group_by(book, chapter) %>%
  summarize(negativewords = n()) %>%
  left_join(wordcounts, by = c("book", "chapter")) %>%
  mutate(ratio = negativewords/words) %>%
  filter(chapter != 0) %>%
  top_n(1) %>%
  ungroup()

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
