library(stringr)
library(readr)
args <- commandArgs(trailingOnly = TRUE)
path <- args[1]
#instpath <- "C:/Users/tva10kg/OneDrive - The Royal Botanic Gardens, Kew/Documents/Projects/PreliminaryGenomeAnal/Scripts/Docker/DockerRun/Output/RHW620_downsB/ABySS_RHW620_downsB/Trimmomatic_hard"
#path <- instpath
####
# checking if a logfile can be found coming from Abyss
####
elogfile <- list.files(path, pattern = "elog")
  if(length(elogfile) == 1){
    elog <- readLines(paste0(path, "/", elogfile))
  }
  if(length(elogfile) > 1){
      warning("More then one logfile was provided! No FPR value will be summarised.")
  }
  if(length(elogfile) == 0){
    warning("No logfile was provided! No FPR value will be summarised.")
  }
######

idx <- which(str_detect(elog, pattern = "\tFPR"))
# extract the second rows as well
idx2 <- idx + 1
FPR <- elog[idx]
kmer <- elog[idx2]
FPR <- str_extract(FPR, pattern = "[0-9]+\\..*%|[0-9]+.*%")
kmer <- str_extract(kmer, pattern = "[0-9]+")
best_k <- kmer[1]
####
# checking if a comparison file can be found coming from abyss-fac
####
compfile <- list.files(path, pattern = "comparison")
  if(length(compfile) == 1){
    comp_df <- read_tsv(paste0(path, "/", compfile), show_col_types = FALSE)
  }
  if(length(compfile) > 1){
    stop("More then one ABySS kmer size comparison file was found!")
  }
  if(length(compfile) == 0){
    stop("No ABySS kmer size comparison file was found!")
  }
######
kmer_comp <- str_extract(comp_df$name, "kmer_\\d+_kc_\\d+")
kmer_comp2 <- str_extract(kmer_comp, "kmer_\\d+")
comp_df$kmer <- str_extract(kmer_comp2, "\\d+")
kc <- str_extract(kmer_comp, "kc_\\d+")
comp_df$kc <- str_extract(kc, "\\d+")
comp_df$FPR <- FPR[match(comp_df$kmer, kmer)]
comp_df$KmerGenieBest <- NA
comp_df$KmerGenieBest[comp_df$kmer %in% best_k] <- "Best K"
comp_df$Best_N50 <- NA
comp_df$Best_N50[which.max(comp_df$N50)] <- "Best N50"
comp_df <- comp_df[order(as.numeric(comp_df$kmer)),]
comp_df <- comp_df[,c(12:16,1:11)]
### write out summary tsv
idx <- which(!is.na(comp_df$KmerGenieBest) | ! is.na(comp_df$Best_N50))
scaffolds <- comp_df$name[idx]
file_out <- str_c(str_remove(compfile, pattern = "_comparison.*"), "_scaffolds_to_anal.txt")
write_lines(scaffolds, file = paste0(path, "/", file_out))
file_out <- str_c(str_remove(compfile, pattern = "_comparison.*"), "_final_summary.tsv")
write_tsv(comp_df, file = paste0(path, "/", file_out))
### move and rename best assembly
# best <- comp_df$name[which.max(comp_df$N50)]
# best_kmer <- comp_df$kmer[which.max(comp_df$N50)]
# best2 <- str_remove(str_extract(str_extract(best, pattern = "kmer_.*"), pattern = "\\/.*.fa"), "\\/")
# newname <- paste0(str_remove(best2, "-scaffolds.fa"), "_kmer", best_kmer, "_ABySS_BestScaffolds.fa")
# system(paste0("cp ", best, " ", path, newname))