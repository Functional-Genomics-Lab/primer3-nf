##Emulating a search

echo $1

nextflow run -resume primer3.nf --genome ./example.fa --targetseq $1
