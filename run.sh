##Emulating a search
seqkit locate -i --gtf -p "ATGGGAGGAGAAGGGTATCGCGG" ~/scratch/Projects/20210918_12B1_v0.3/12B1_scaffolds_v0.3.fasta > target.gtf
seqkit subseq --gtf target.gtf -u 500 -d 500 ~/scratch/Projects/20210918_12B1_v0.3/12B1_scaffolds_v0.3.fasta > target.fa


nextflow run -resume primer3.nf --genome ~/scratch/Projects/20210918_12B1_v0.3/12B1_scaffolds_v0.3.fasta --target target.fa
