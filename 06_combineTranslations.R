
DATA_DIR <- '/Users/ge23huw/tumProjects/Query Translation/data/'
languageCode <- "es"
filePath <- paste0("intermediate/", languageCode, "/")

listFile <- paste0(DATA_DIR, filePath)
setwd(listFile)

translateFiles <- list.files(pattern = "indexed_p")

# Load all docs
for (i in 1:length(translateFiles)) {
  
  tempDF <- readRDS(paste0(listFile, translateFiles[[i]]))
  assign(paste0("df_", i), tempDF)
}

library(dplyr)
library(tidyr)

dfs <- ls(pattern = "df_")
allDFs <- list()
for(i in 1:length(dfs)) {
  allDFs <- append(allDFs, list(get(dfs[i])))
}

# Combine Docs
df_full <- bind_rows(allDFs) %>% 
  distinct(sentence_id, .keep_all = TRUE)

rm(list=setdiff(ls(), c("df_full", "languageCode", "DATA_DIR", "filePath", "listFile")))

# Reformat to Document Level rather than sentence level  

df_cl <- df_full %>% 
  separate(sentence_id, into = c("document_id", "sentence_id"), sep = "\\.")

rm(df_full)
gc()

df_cl$sentence_id = as.numeric(df_cl$sentence_id)

# Merge into documents 
source_full <- df_cl %>% 
  group_by(document_id) %>% 
  summarise(document_text = paste0(source_raw, collapse = " ")) 

target_full <- df_cl %>% 
  group_by(document_id) %>% 
  summarise(document_text = paste0(target_hf, collapse = " ")) 

rm(df_cl)
gc()

source_target_full <- inner_join(source_full, target_full, by = c("document_id"))

names(source_target_full) <- c("document_id", "text_source", "text_target")

makeTitle <- function(x) {
  return(paste(stringr::word(x, 1:3), collapse = "TTT"))
}

rm(source_full, target_full)
gc()

source_title <- lapply(source_target_full$text_source, makeTitle)
target_title <- lapply(source_target_full$text_target, makeTitle)

full_title <- stringr::str_replace_all(
  stringr::str_replace_all(
    paste(source_title, target_title, sep = "TTT"), 
    "[[:punct:]]", ""), 
  "TTT", "_")

rm(source_title, target_title)

source_target_full$title <- full_title

#head(source_target_full, 5)

# Convert to quanteda corpus
library(quanteda)
source_full_cl <- corpus(source_target_full, text = "text_source")
source_full_cl$text_target <- NULL
source_full_cl$country <- languageCode

summary(source_full_cl[1:3])

target_full_cl <- corpus(source_target_full, text = "text_target")
target_full_cl$text_source <- NULL
target_full_cl$country <- languageCode

summary(target_full_cl[1:3])

# Should have the same number of sentences...

source_json <- convert(source_full_cl, to = 'json')
target_json <- convert(target_full_cl, to = 'json')

write(source_json, paste0(DATA_DIR, "final/", languageCode, "_en_translated_full.json"))
write(target_json, paste0(DATA_DIR, "final/en_", languageCode, "_translated_full.json"))
saveRDS(source_target_full, paste0(DATA_DIR, "final/en_", languageCode, "_translated_full.rds"))
