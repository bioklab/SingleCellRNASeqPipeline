#!/usr/bin/env Rscript

# ---- Config ----
cellranger     <- "/home/BioKLabPipeline/sc.rna.seq/cellranger-10.1.0/cellranger"
transcriptome  <- "/home/BioKLabPipeline/sc.rna.seq/refdata-gex-GRCh38-2020-A"
fastq.dir      <- "fastq"
log.dir        <- "logs"
include.intron <- "true"
create.bam     <- "true"
localcores     <- 32
localmem       <- 100

# ---- Samples: CSV with columns sample.raw.data.id, sample.barcode ----
args <- commandArgs(TRUE)
if (length(args) < 1) {
  message("Please indicate a csv file")
  quit()
}
sample.df <- read.csv(args[1], stringsAsFactors = FALSE)

required.cols <- c("sample.raw.data.id", "sample.barcode")
missing.cols  <- setdiff(required.cols, names(sample.df))
if (length(missing.cols) > 0) {
  message(sprintf("CSV is missing required column(s): %s",
                  paste(missing.cols, collapse = ", ")))
  message(sprintf("Columns found: %s", paste(names(sample.df), collapse = ", ")))
  quit(status = 1)
}

dir.create(log.dir, showWarnings = FALSE)

# ---- Per-sample processing ----
for (i in seq_len(nrow(sample.df))) {
  row <- sample.df[i, ]

  h5.file <- file.path(row$sample.barcode, "outs", "filtered_feature_bc_matrix.h5")
  if (file.exists(h5.file)) {
    message(sprintf("Output exists for sample %s, skipping.", row$sample.barcode))
    next
  }

  
  fastqs <- list.files(fastq.dir)
  fastqs <- fastqs[startsWith(fastqs, row$sample.raw.data.id)]
  if (length(fastqs) == 0) {
    message(sprintf("No FASTQs found for sample %s, skipping.", row$sample.raw.data.id))
    next
  }
  
  sample.name <- fastqs |>
    sapply(\(x) strsplit(x, "_")[[1]][1]) |>
    unique() |>
    paste(collapse = ",")

  cmd.args <- c(
    "count",
    paste0("--id=",            row$sample.barcode),
    paste0("--fastqs=",        fastq.dir),
    paste0("--sample=",        sample.name),
    paste0("--transcriptome=", transcriptome),
    paste0("--localcores=",    localcores),
    paste0("--localmem=",      localmem),
    paste0("--include-introns=", include.intron),
    paste0("--create-bam=",      create.bam),
    "--nosecondary",
    "--disable-ui"
  )
  log.file <- file.path(log.dir, paste0(row$sample.barcode, ".cellranger.count.log"))
  status <- system2(cellranger, cmd.args,
                    stdout = log.file, stderr = log.file, wait = TRUE)

  if (status != 0 || !file.exists(h5.file)) {
    message(sprintf("Error processing sample %s (see %s)", row$sample.barcode, log.file))
  } else {
    message(sprintf("Sample %s processed successfully.", row$sample.barcode))
  }
}
