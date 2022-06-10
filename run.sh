##Emulating a search

echo $1

nextflow run -resume primer3.nf --genome ~/scratch/Projects/20210918_12B1_v0.3/12B1_scaffolds_v0.3.fasta --targetseq $1
