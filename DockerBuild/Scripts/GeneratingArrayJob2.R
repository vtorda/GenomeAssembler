library(stringr)
library(readr)
args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1] # # the place of libraries, also other files created by this script will be place here
output_path <- args[2]  # the folder where the genome anal out will be placed
samples <- args[3] #a txt file with the sample name (without the strand and fastq.gz suffix)
env_file <- args[4] # the name of the template environment file
slurm_job <- args[5] # slurm job name
partition <- args[6] # cluster partition name "long"
cpu <- args[7] # number of threads per task 20
mem <- args[8] # memory per task in gigabase 32
email <- args[9] # email adress "t.varga@kew.org"
n_tasks <- args[10] # number of task at a time 10
sif_file <- args[11] # container file with path to it "/home/tvarga/scratch/apps/assembly_v0.08246R_latest.sif"
script <- "master25.sh"

env_template <- readLines(paste0(input_path, "/", env_file))
sample_list <- readLines(paste0(input_path, "/", samples))
input_files <- list.files(input_path)
library_list <- c(str_c(sample_list, "_1.fastq.gz"), str_c(sample_list, "_2.fastq.gz"))
# files_there <- unique(unlist(str_extract_all(input_files, paste(sample_list, collapse = "|"))))
# files_exist <- sample_list %in% files_there
# if(all(files_exist)){
#   cat("\nAll sample are probably in the folder")
# }else{
#   not_detected <- sample_list[!files_exist] 
#   cat("\nThe following samples has not been detected:\n", not_detected)
# }
library_formatok <- library_list %in% input_files
if(all(library_formatok)){
  cat("\nAll libraries in the right format")
}else{
  not_detected <- library_list[!library_formatok] 
  cat("\nThe following libraries were not in the write format [sample_name_1.fastq.gz and sample_name_2.fastq.gz] has not been detected:\n", not_detected)
}
input_files2 <- input_files[input_files %in% library_list]

input_temp <- str_remove(input_files2, pattern = "_1.fastq.gz|_2.fastq.gz")
#cat(names(table(input_temp) == 2))

# paired_libs <- sapply(sample_list, function(x) sum(str_detect(input_files2, x)))
# selected_libraries <- names(paired_libs)[paired_libs == 2]

#selected_libraries <- unique(input_temp)

selected_libraries <- names(table(input_temp) == 2)
sample_list2 <- sample_list[sample_list %in% selected_libraries]
selected_libraries <- selected_libraries[match(sample_list2, selected_libraries)]
env_files <- vector()
for(i in 1:length(selected_libraries)){
  lib <- selected_libraries[i]
  lib_env <- env_template
  lib_env[str_detect(lib_env, "FILE_base=")] <- paste0("\tFILE_base=", lib)
  env_file_name <- paste0("environment_file_", lib, ".env")
  env_files[i] <- env_file_name
  writeLines(lib_env, paste0(input_path, "/", env_file_name), sep = "\n")
}
cat("\nEnvironment files has been created for the following samples:", selected_libraries, "\nNumber of samples: ", length(selected_libraries))
n_alltasks <- length(selected_libraries)

config_file <- data.frame(ArrayTaskID = 1:n_alltasks, env_files=env_files)
write_tsv(config_file, paste0(input_path, "/", slurm_job, ".config"))
sink(paste0(input_path, "/", slurm_job, "_array_job_.sh"))
cat("#!/bin/bash\n\n#SBATCH --job-name=\"", slurm_job,
    "\"\n#SBATCH --export=ALL\n#SBATCH --partition=", partition,
    "\n#SBATCH --cpus-per-task=", cpu,
    "\n#SBATCH --mem=", mem,
    "G\n#SBATCH --output=", slurm_job,
    "%A_%a.log\n#SBATCH --error=", slurm_job,
    "%A_%a.elog\n#SBATCH --mail-user=",email, "\n#SBATCH --mail-type=END,FAIL\n#SBATCH -a 1-", n_alltasks, "%",n_tasks,
    "\n\n\n#To set up environment variables I follow the following blog: https://blog.ronin.cloud/slurm-job-arrays/ \n# Specify the path to the config file\nconfig=", paste0(input_path, "/", slurm_job, ".config"), 
    "\n# Extract the environment file name for the current $SLURM_ARRAY_TASK_ID\nenvfile=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)\nsingularity run --cleanenv --no-home --env-file ", input_path, "/${envfile} --bind ", input_path,":/home/repl/Input --bind ", output_path,":/home/repl/Output ", sif_file, " ", script, sep ="")
sink()

