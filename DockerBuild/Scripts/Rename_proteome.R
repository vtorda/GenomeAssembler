library(seqinr)
library(stringr)
library(readr)
args <- commandArgs(trailingOnly = TRUE)
path <- args[1] 
#path <- "/Users/tva10kg/The Royal Botanic Gardens, Kew/Darwin Tree of Life - HERICIUM/JosephaBecker/Genomics/Genomic_Pipeline_Reports/HerCora3/"
proteome_fasta <- args[2]
#proteome_fasta <- "HerCora3.aa"
coding <- args[3]
#coding <- "HerCora3.codingseq"
gtf <- args[4]
#gtf <- "HerCora3.gtf"
species <- args[5]
#species <- "HerCora3"

prot <- read.fasta(paste0(path, "/", proteome_fasta), seqtype = "AA", forceDNAtolower = FALSE)

n <- names(prot)
n2 <- str_extract(n, "g\\d+")
t <- str_extract(n, "t\\d+")
n3 <- str_extract(n2, "\\d+")
new_name <- str_c("rbgk_", species, "_", n3, "_", t)
new_gene <- str_c("rbgk_", species, "_", n3)
prot_header <- data.frame(Transcript_old = n, Transcript_new = new_name, Gene_old = n2, Gene_new = new_gene, stringsAsFactors = FALSE)
if(all(names(prot) == prot_header$Transcript_old)){
  write.fasta(prot, names = prot_header$Transcript_new, file.out = paste0(path, "/", species, "_renamed.aa"))
}


coding_seq <- read.fasta(paste0(path, "/", coding), seqtype = "DNA", forceDNAtolower = FALSE)
if(all(names(coding_seq) == prot_header$Transcript_old)){
  write.fasta(coding_seq, names = prot_header$Transcript_new, file.out = paste0(path, "/", species, "_renamed.codingseq"))
}else{
  cat("Coding seq headers are not matching")
}

gtf_file <- read_file(paste0(path, "/", gtf))
cat("Renaming gtf file has started:\nTranscript ID\n")
for(i in 1:nrow(prot_header)){
  if(i %% 500 == 0){cat(i, "\n")}
  gtf_file <- str_replace_all(gtf_file, paste0("\"", prot_header$Transcript_old[i], "\""),
                  paste0("\"", prot_header$Transcript_new[i], "\""))
  gtf_file <- str_replace_all(gtf_file, paste0("\t", prot_header$Transcript_old[i], "\n"),
                              paste0("\t", prot_header$Transcript_new[i], "\n"))
  
}
cat("Renaming gtf file has started:\nGene ID\n")
for(i in 1:nrow(prot_header)){
  if(i %% 500 == 0){cat(i, "\n")}
  gtf_file <- str_replace_all(gtf_file, paste0("\"", prot_header$Gene_old[i], "\""),
                              paste0("\"", prot_header$Gene_new[i], "\""))
  gtf_file <- str_replace_all(gtf_file, paste0("\t", prot_header$Gene_old[i], "\n"),
                              paste0("\t", prot_header$Gene_new[i], "\n"))
}
write_file(gtf_file, paste0(path, "/", species, "_renamed.gtf") )
