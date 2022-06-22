##Emulating a search

echo $1

nextflow run -resume primer3.nf --genome examples/example.fa --targetseq $1

## Zipping up results.
for D in $(ls -1 results/ | grep -P "primer3|seqkit" | grep -vP ".zip|_index")
do
zip results/${D}.zip -r results/${D}
done
