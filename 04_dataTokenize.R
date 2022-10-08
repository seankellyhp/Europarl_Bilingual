
library(quanteda)

DATA_DIR <- 'PROJECT DIRECTORY'
languageCode <- 'es'
filePath <- paste0("intermediate/", languageCode, "/")

full.corpus <- readRDS(paste0(DATA_DIR, "tidy/corp_",languageCode,"-en_en_complete_v2.rds"))


# Split file into sentences 

sentence.corpus <- corpus_reshape(full.corpus, to = "sentences")
rm(full.corpus)

# Convert sentences to hashes 
library(digest)

allHashes <- sapply(texts(sentence.corpus), digest, "md5", serialize = FALSE)
sentence.corpus$hashes <- allHashes

saveRDS(allHashes, paste0(DATA_DIR, filePath, "full_sample_en_hash.rds"))
saveRDS(sentence.corpus, paste0(DATA_DIR, filePath, "hashed_full_sample.rds"))

rm(allHashes)
rm(sentence.corpus)
gc()