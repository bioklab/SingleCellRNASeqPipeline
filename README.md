##
1.Create a folder named fast, put all fastq files under this folder (or create soft links to fastq files)
##
2. Prepare a CSV file as follows:
"
sample.raw.data.id,sample.barcode
N872575,CLM-872575-N-03
P872575,CLM-872575-P-03
P938628,CLM-938628-P-03
N988263,CLM-988263-N-03
P988263,CLM-988263-P-03
N546908,CLM-546908-N-03
T546908,CLM-546908-T-03
"
sample.raw.data.id: the sample name submitted to sequencing facility. Usually, the name of fastq files for the sample starts with this.
sample.barcode:     the sample barcode we would like to use in the downstream analysis. Usually, the sample.raw.data.id is pretty arbitrary and not self-descriptive. This provides us an opportunity to re-name the sample

##
3. Rscript sc.rna.seq.pipeline.R CSV_file_name
