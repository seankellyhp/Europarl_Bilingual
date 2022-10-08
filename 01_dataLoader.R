
# 
DATA_DIR <- '/Users/ge23huw/tumProjects/Query Translation/data/'

languageCode <- 'es'
filePath <- paste0("intermediate/", languageCode, "/")

filename <- paste0("europarl/",languageCode,"-en/europarl-v7.",languageCode,"-en.en.txt")
savePath <- paste0(filePath,"europarl-v7.",languageCode,"-en.en")

data.size <- length(readLines(paste0(DATA_DIR, filename)))
data.size <- as.numeric(data.size)

# Split File into equal parts 
n = 25
d <- 1:data.size
splits <- split(d, sort(d%%n))

for(i in 1:n) {
  maxSplit <- as.numeric(tail(splits[[i]], n=1))
  minSplit <- as.numeric(head(splits[[i]], n=1))
  
  data.txt <- paste(readr::read_lines(paste0(DATA_DIR, filename), skip = minSplit-1, n_max = maxSplit-minSplit), collapse = ' ')
  
  saveRDS(data.txt, paste0(DATA_DIR, savePath, "_", 
                           minSplit, "_", maxSplit, ".rds"))
  rm(data.txt)
  
}
