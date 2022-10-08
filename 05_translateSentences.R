
# Load translated sentences 
DATA_DIR <- '/Users/ge23huw/tumProjects/Query Translation/data/'
languageCode <- "es"
filePath <- paste0("intermediate/", languageCode, "/")

library(reticulate)
use_condaenv("datasets")

source_python('/Users/ge23huw/TUM/HuggingFace/europarl_fn_full.py') 

library(quanteda)
library(digest)
library(dplyr)
library(tidyr)

#set.seed(001)
#set.seed(002)
#set.seed(003)
#set.seed(004)

# Load HuggingFace Translations
langKey <- tryCatch(europarl_sample(languageCode, "en"), 
                    error = function(x){
                      message('try other way around')
                      return(NA)
                    })

if(is.na(langKey)) {
  langKey <- europarl_sample("en", languageCode)
}

names(langKey) <- c("index", "source", "target")


n = 25
split_index = split(langKey$index, sort(langKey$index%%n))

# Split - Apply - Combine Approach 

full.corpus <- readRDS(paste0(DATA_DIR, filePath, "hashed_full_sample.rds"))
full.corpus.df <- convert(full.corpus, to = "data.frame")
rm(full.corpus)

for(i in 1:n)  {
  # Hash translated sentences 
  
  translate.corpus <- corpus(filter(langKey, index %in% split_index[[i]]), text = 'source')
  
  translateHashes <- sapply(texts(translate.corpus), digest, "md5", serialize = FALSE)
  translate.corpus$hashes <- translateHashes
  
  #summary(translate.corpus[1])
  #summary(translate.corpus[2])
  #summary(translate.corpus[3])
  
  # Compare hash of first sentence to translated sentence, 
  
  allHashes <- readRDS(paste0(DATA_DIR, filePath, "full_sample_en_hash.rds"))
  
  joinHashes <- intersect(allHashes, translateHashes)
  
  #if match then add original sentence as new column 
  
  match.corpus <- corpus_subset(translate.corpus, hashes %in% joinHashes)
  
  rm(allHashes, translateHashes)
  rm(joinHashes, translate.corpus)
  
  match.corpus.df <- convert(match.corpus, to = "data.frame")
  rm(match.corpus)
  
  #### Need to check format for other languages
  # Works 
  translated_df <- inner_join(full.corpus.df, match.corpus.df, by = c("hashes")) %>% 
    select('sentence_id'=doc_id.x, 'hf_sentence_id'=doc_id.y,'source_raw'=text.x, 'target_hf' = target, pattern, hashes) %>% 
    distinct(sentence_id, .keep_all = TRUE)
  
  rm(match.corpus.df)
  
  saveRDS(translated_df, paste0(DATA_DIR, filePath, "joined_full_indexed_p", i, ".rds"))
}