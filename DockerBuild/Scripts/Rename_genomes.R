library(seqinr)
library(stringr)
library(readr)
args <- commandArgs(trailingOnly = TRUE)
path <- args[1] 
genome_fasta <- args[2]
species <- args[3]
genome <- read.fasta(paste0(path, "/", genome_fasta), seqtype = "DNA", forceDNAtolower = FALSE)
scaffold_length <- sapply(genome, length)
scaffold_length <- scaffold_length[order(scaffold_length, decreasing = TRUE)]
genome2 <- genome[match(names(scaffold_length), names(genome))]
original_name <- getName(genome2)
names(genome2) <- str_c(species, "_scaffold_", 1:length(genome2))
df <- data.frame(original_name = original_name,
                 new_name = names(genome2), length = scaffold_length, stringsAsFactors = FALSE)
out_name <- str_remove(genome_fasta, ".fasta")
write_tsv(df, file = paste0(path, "/", out_name, "_names.tsv"))
write.fasta(genome2, names = names(genome2), file.out = paste0(path, "/", out_name, "_renamed.fasta"))