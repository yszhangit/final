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

original_books

tidy_books <- original_books %>% unnest_tokens(word, text)
tidy_books

# 