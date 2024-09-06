library(stringr)
library(readr)
args <- commandArgs(trailingOnly = TRUE)
path <- args[1]
threads <- args[2]
genom_size <- args[3]
kmer_size <- args[4]
output <- args[5]
#path <- "C:/Users/tva10kg/OneDrive - The Royal Botanic Gardens, Kew/Documents/Projects/PreliminaryGenomeAnal/Scripts/Docker/DockerRun/Output/RHW620_downsB/Trimmomatic_RHW620_downsB/Trimmomatic_hard"
#output <- "C:/Users/tva10kg/OneDrive - The Royal Botanic Gardens, Kew/Documents/Projects/PreliminaryGenomeAnal/Scripts/Docker/DockerRun/Output/RHW620_downsB/Masurca_RHW620_downsB/Trimmomatic_hard_kmergenie"
#threads <- 4
#genom_size <- 981211
#kmer_size <- "auto"
# calculate read length mean and sd
files <- list.files(path = path, pattern = "fastq.gz")
for(i in 1:length(files)){
  system(paste0("gzip -d -k ", path, "/", files[i], " -c > ", output, "/read_", i, ".fastq"))
}
files2 <- list.files(path = output, pattern = "fastq")
input_data <- as.data.frame(matrix(nrow = length(files2), ncol = 4))
colnames(input_data) <- c("files", "mean", "sd", "files_origin")
for(i in 1:length(files2)){
 # incon <- gzcon(file(paste0(path, "/", files[i]),open="rb"))
  #fastq <- readLines(incon)
  fastq <- readLines(paste0(output, "/", files2[i]))
  idx <- which(str_detect(fastq, pattern = "^@"))
  idx2 <- idx + 1
  seq_length <- nchar(fastq[idx2])
  input_data[i,1] <- paste0(output, "/", files2[i])
  input_data[i,2] <- mean(seq_length) # mean length
  input_data[i,3] <- sd(seq_length) # sd
  input_data[i,4] <- paste0(path, "/", files[i])
}
idx <- apply(input_data, 1, function(x) any(is.na(x))) # delete rows that may contain NA BC fastq didn't contain reads
input_data <- input_data[!idx,]
paired_idx <- str_detect(input_data[,4], "Pair")
single_idx <- str_detect(input_data[,4], "Single")
#create config file
if(sum(single_idx) == 2){
  sink(file = paste0(output, "/config.txt"))
  cat("DATA\n",
    "PE= pe ", median(input_data[paired_idx,2]), " ", median(input_data[paired_idx,3]), " ", input_data$files[paired_idx][1], " ",  input_data$files[paired_idx][2], "\n",
    "PE= s1 ", input_data[single_idx,2][1], " ", input_data[single_idx,3][1], " ", input_data$files[single_idx][1], "\n",
    "PE= s2 ", input_data[single_idx,2][2], " ", input_data[single_idx,3][2], " ", input_data$files[single_idx][2], "\n",
    "END\n",
    "PARAMETERS\n",
    "EXTEND_JUMP_READS=0\n",
    "GRAPH_KMER_SIZE = ", kmer_size, "\n",
    "USE_LINKING_MATES = 1\n",
    "USE_GRID=0\n",
    "GRID_ENGINE=SGE\n",
    "GRID_QUEUE=all.q\n",
    "GRID_BATCH_SIZE=500000000\n",
    "LHE_COVERAGE=25\n",
    "MEGA_READS_ONE_PASS=0\n",
    "LIMIT_JUMP_COVERAGE = 300\n",
    "CA_PARAMETERS =  cgwErrorRate=0.15\n",
    "CLOSE_GAPS=1\n",
    "NUM_THREADS = ", threads, "\n",
    "JF_SIZE = ", as.numeric(genom_size) * 10, "\n",
    "SOAP_ASSEMBLY=0\n",
    "FLYE_ASSEMBLY=0\n",
    "END\n", sep =  "")
  sink()
}
if(sum(single_idx) < 2){
  sink(file = paste0(output, "/config.txt"))
  cat("DATA\n",
      "PE= pe ", median(input_data[paired_idx,2]), " ", median(input_data[paired_idx,3]), " ", input_data$files[paired_idx][1], " ",  input_data$files[paired_idx][2], "\n",
      "END\n",
      "PARAMETERS\n",
      "EXTEND_JUMP_READS=0\n",
      "GRAPH_KMER_SIZE = ", kmer_size, "\n",
      "USE_LINKING_MATES = 1\n",
      "USE_GRID=0\n",
      "GRID_ENGINE=SGE\n",
      "GRID_QUEUE=all.q\n",
      "GRID_BATCH_SIZE=500000000\n",
      "LHE_COVERAGE=25\n",
      "MEGA_READS_ONE_PASS=0\n",
      "LIMIT_JUMP_COVERAGE = 300\n",
      "CA_PARAMETERS =  cgwErrorRate=0.15\n",
      "CLOSE_GAPS=1\n",
      "NUM_THREADS = ", threads, "\n",
      "JF_SIZE = ", as.numeric(genom_size) * 10, "\n",
      "SOAP_ASSEMBLY=0\n",
      "FLYE_ASSEMBLY=0\n",
      "END\n", sep =  "")
  sink()
}

