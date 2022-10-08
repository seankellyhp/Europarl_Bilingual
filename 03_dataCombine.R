
DATA_DIR <- 'PROJECT DIRECTORY'
languageCode <- 'es'
filePath <- paste0("intermediate/", languageCode, "/")

# Split file 
library(quanteda)
library(digest)

# load file 
allFiles <- list.files(path = paste0(DATA_DIR, filePath), pattern = "corp_")

full.corpus <- readRDS(paste0(DATA_DIR, filePath, allFiles[[1]]))
temp.corpus <- readRDS(paste0(DATA_DIR, filePath, allFiles[[2]]))

textHashes <- sapply(docnames(full.corpus), digest, "md5", serialize = FALSE)
docnames(full.corpus) <- paste(textHashes, sample(1:ndoc(full.corpus), ndoc(full.corpus)), sep = "_")

textHashes <- sapply(docnames(temp.corpus), digest, "md5", serialize = FALSE)
docnames(temp.corpus) <- paste(textHashes, sample(1:ndoc(temp.corpus), ndoc(temp.corpus)), sep = "_")

full.corpus <- c(full.corpus, temp.corpus)

for (i in 3:length(allFiles)) {
  
  temp.corpus <- readRDS(paste0(DATA_DIR, filePath, allFiles[[i]]))
  
  textHashes <- sapply(docnames(temp.corpus), digest, "md5", serialize = FALSE)
  docnames(temp.corpus) <- paste(textHashes, sample(1:ndoc(temp.corpus), ndoc(temp.corpus)), sep = "_")
  
  full.corpus <- c(full.corpus, temp.corpus)
  rm(temp.corpus)
}

head(docnames(full.corpus))

saveRDS(full.corpus, paste0(DATA_DIR, "tidy/corp_",languageCode,"-en_en_complete_v2.rds"))