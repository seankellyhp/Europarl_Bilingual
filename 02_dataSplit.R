
DATA_DIR <- '/Users/ge23huw/tumProjects/Query Translation/data/'
languageCode <- 'es'
filePath <- paste0("intermediate/", languageCode, "/")

# Split file 
library(quanteda)
library(digest)

# load file 
allFiles <- list.files(path = paste0(DATA_DIR, filePath), pattern = ".rds") #give tmp dir then delete

# Load a batch and split 

for (i in 1:length(allFiles)) {
  
  data.raw <- readRDS(paste0(DATA_DIR, filePath, allFiles[[i]]))
  data.corp <- corpus(as.character(data.raw))
  
  # Debate Split
  data.split <- corpus_segment(data.corp, pattern = "The debate is closed.|The joint debate is closed.|Written statements ", pattern_position = "before", valuetype = "regex")
  
  rm(data.corp)
  
  # Question Split 
  
  data.split$flag_questions <- stringi::stri_detect_regex(data.split, "Question No ",
                                                              case_insensitive = FALSE
  )
  
  data_questions <- corpus_subset(data.split, flag_questions == TRUE)
  data_no_questions <- corpus_subset(data.split, flag_questions == FALSE)
  
  data_full <- data_no_questions
  rm(data_no_questions, data.split)
  
  textHashes <- sapply(texts(data_full), digest, "md5", serialize = FALSE)
  docnames(data_full) <- paste(textHashes, docnames(data_full), sample(1:ndoc(data_full), ndoc(data_full)), sep = "_")
  rm(textHashes)
  
  if (ndoc(data_questions) >= 1) {
  for (j in 1:ndoc(data_questions)) {
    
    corpus.split <- corpus_segment(data_questions[j], pattern = "Question No ", pattern_position = "before", valuetype = "regex")
    
    textHashes <- sapply(texts(corpus.split), digest, "md5", serialize = FALSE)
    docnames(corpus.split) <- paste(textHashes, docnames(corpus.split), sample(1:ndoc(corpus.split), ndoc(corpus.split)), sep = "_")
    rm(textHashes)
    
    data_full <- c(data_full, corpus.split)
    
  }
  } 
  
  rm(data_questions)
  
  # Item Split
  
  data_full$flag_item <- stringi::stri_detect_regex(data_full, "the next item ",
                                                       case_insensitive = TRUE
  )
  
  data_item <- corpus_subset(data_full, flag_item == TRUE)
  data_no_item <- corpus_subset(data_full, flag_item == FALSE)
  
  data_full2 <- data_no_item
  rm(data_no_item, data_full)
  
  textHashes <- sapply(texts(data_full2), digest, "md5", serialize = FALSE)
  docnames(data_full2) <- paste(textHashes, docnames(data_full2), sample(1:ndoc(data_full2), ndoc(data_full2)), sep = "_")
  rm(textHashes)
  
  if (ndoc(data_item) >= 1) {
  # Duplicated Document Names
  for (j in 1:ndoc(data_item)) {
    
    corpus.split <- corpus_segment(data_item[j], pattern = "the next item ", pattern_position = "before", case_insensitive = TRUE, valuetype = "regex")
    
    textHashes <- sapply(texts(corpus.split), digest, "md5", serialize = FALSE)
    docnames(corpus.split) <- paste(textHashes, docnames(corpus.split), sample(1:ndoc(corpus.split), ndoc(corpus.split)), sep = "_")
    rm(textHashes)
    
    data_full2 <- c(data_full2, corpus.split)
    
  }
  }
  
  rm(data_item)
  
  # Save 
  saveRDS(data_full2, paste0(DATA_DIR, filePath, "/corp_", allFiles[[i]]))
  
}





