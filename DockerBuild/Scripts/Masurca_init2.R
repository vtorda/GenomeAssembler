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
# for(i in 1:length(files)){
#   system(paste0("gzip -d -k ", path, "/", files[i], " -c > ", output, "/read_", i, ".fastq"))
# }
#files2 <- list.files(path = output, pattern = "_fastq")
files2 <- str_remove(files, ".gz")
input_data <- as.data.frame(matrix(nrow = 4, ncol = 2))
colnames(input_data) <- c("Input_fastq", "Input_fastqgz")
input_data$Input_fastq[1:length(files2)] <- str_c(output, "/", files2)
input_data$Input_fastqgz[1:length(files)] <- str_c(path, "/", files)
# input_data <- data.frame(Input_fasta = str_c(output, "/", files2),
#                          Input_fastq = str_c(path, "/", files))
#colnames(input_data) <- c("files", "mean", "sd", "files_origin")
stat_file <- list.files(path, pattern = "readstat.txt")
readstat <- readLines(paste0(path, "/", stat_file))
idx <- str_detect(readstat, "PairedRead")
paired_mean <- str_remove(str_extract(readstat[idx], "avg=\\d+.\\d+"), "avg=")
paired_sd <- str_remove(str_extract(readstat[idx], "stddev=\\d+.\\d+"), "stddev=")
readstat_single <- readstat[!idx]
single_df <- as.data.frame(do.call(rbind, str_split(readstat_single, " ")))
single_idx2 <- str_detect(single_df[,1], "Single")

paired_idx <- str_detect(input_data[,2], "Pair")
single_idx <- str_detect(input_data[,2], "Single")
#input_single <- input_data[single_idx,]
#input_single <- input_single[as.numeric(input_single[,4]) > 0,]
#single_idx2 <- str_detect(input_single[,1], "Single")
#single_idx <- c(F,F,T,T)

#create config file
if(sum(single_idx2) == 2){
  single1_mean <- str_extract(single_df[3,5], "\\d+.\\d+")
  single1_sd <- str_extract(single_df[3,6], "\\d+.\\d+")
  single2_mean <- str_extract(single_df[4,5], "\\d+.\\d+")
  single2_sd <- str_extract(single_df[4,6], "\\d+.\\d+")
  sink(file = paste0(output, "/config.txt"))
  cat("DATA\n",
    "PE= pe ", paired_mean, " ", paired_sd, " ", input_data$Input_fastq[paired_idx][1], " ",  input_data$Input_fastq[paired_idx][2], "\n",
    "PE= s1 ", single1_mean, " ", single1_sd, " ", input_data$Input_fastq[single_idx][1], "\n",
    "PE= s2 ", single2_mean, " ", single2_sd, " ", input_data$Input_fastq[single_idx][2], "\n",
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
if(sum(single_idx2) < 2){
  sink(file = paste0(output, "/config.txt"))
  cat("DATA\n",
      "PE= pe ", paired_mean, " ", paired_sd, " ", input_data$Input_fastq[paired_idx][1], " ",  input_data$Input_fastq[paired_idx][2], "\n",
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

