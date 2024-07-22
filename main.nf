nextflow.enable.dsl=2

process seqkit_fetch_target {
conda "seqkit"
input:
 val seq
 path fasta
output:
 path "${seq}_target.fa" , emit:fasta
 path "${seq}_target.gtf" , emit:gtf
shell:
'''
echo ">seq
!{seq}
" > seq.fa

seqkit locate -i --gtf -p "!{seq}" !{fasta} > !{seq}_target.gtf

seqkit subseq --gtf !{seq}_target.gtf -u 50000 -d 50000 !{fasta} > !{seq}_target.fa

if [[ ! -s !{seq}_target.gtf ]]
then
exit 7
fi

seqkit stat !{seq}_target.gtf
seqkit stat !{seq}_target.fa
'''
}

process primer3_index {
    conda "genometester4"
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"
    input:
      path fasta    
    output:
      path "${fasta}*.list"
    shell:
'''
glistmaker !{fasta} -w 11          
glistmaker !{fasta} -w 16          
ln out_11.list !{fasta}_11.list
ln out_16.list !{fasta}_16.list
'''
}

process primer3_conf {
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"
    input:
      path fasta
      path target    
    output:
      path "custom_primer3.conf"
    shell:
'''
##The MASK_KMERLIST does give an error if run with a dummy value, so expect it is working?
## See the Primer3 manual for details on these parameters

## The "SEQUENCE_TARGET" parameter is fairly important, as that ensures the PCR product goes across the gRNA site
## It should be the value of the `-u` parameter in seqkit_fetch_target
##
## The SEQUENCE_EXCLUDED_REGION ensures it doesn't pick a product right on the gRNA site
## It should be the value of the `-u` parameter in seqkit_fetch_target, minus 1 half of 70 (35)
## 
##

echo "SEQUENCE_ID=$(seqkit fx2tab !{target} | cut -f 1)
SEQUENCE_TEMPLATE=$(seqkit fx2tab !{target} | cut -f 2)
SEQUENCE_TARGET=50000,20
SEQUENCE_EXCLUDED_REGION=49965,70
PRIMER_TASK=generic
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=0
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_OPT_SIZE=20
PRIMER_MIN_SIZE=18
PRIMER_MAX_SIZE=22
PRIMER_PRODUCT_SIZE_RANGE=75-500
PRIMER_EXPLAIN_FLAG=1
PRIMER_MASK_TEMPLATE=1
PRIMER_MASK_KMERLIST_PREFIX=!{fasta}
PRIMER_MASK_KMERLIST_PATH=./kmer_lists/
=" > custom_primer3.conf      
'''
}

process primer3_calc {
    conda "primer3"
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$kmer_lists $conf"
    input:
      path conf
      path kmer_lists    
    output:
      path "*primer3.txt"
    shell:
'''
mkdir -p kmer_lists
ln ./*.list kmer_lists

ID=$(head -n 1 !{conf} | cut -f 2 -d '=' | cut -f 2 -d ' ')

primer3_core -h 2>&1 | grep "This is primer3" > ${ID}_primer3.txt
cat ${ID}_primer3.txt ## Print version to stdout
primer3_core !{conf} >> ${ID}_primer3.txt
'''
}

process primer3_results2fasta {
publishDir "results/${task.process}",mode:'link',overwrite:'true'
cache 'deep'
input:
 path results
output:
 path "${results}.fa"
tag "$results"
shell:
'''
#!/usr/bin/env python
import re
import os
import os.path
print("hello world!")

with open("!{results}", "r") as input_handle:
    data = input_handle.read()
##print(data)

id_match = re.search('SEQUENCE_ID=(.+)',data)
id = id_match.group(1)

bespoke_regex = '(?P<id>PRIMER_PAIR_[0-9]+)_PENALTY=(?P<penalty>[0-9.]+).+?PRIMER_LEFT_[0-9]+_SEQUENCE=(?P<left>[atcgATCGnN]+).+?PRIMER_RIGHT_[0-9]+_SEQUENCE=(?P<right>[atcgATCGnN]+).+?PRIMER_PAIR_[0-9]+_PRODUCT_SIZE=(?P<size>[0-9]+).+?PRIMER_PAIR_[0-9]+_PRODUCT_TM=[0-9.]+'

matches = list(re.finditer(bespoke_regex,data,flags=re.MULTILINE|re.DOTALL))

output_handle = open("!{results}.fa", "w")
for m in matches:
    line = ">{ID} primer3 {SUBID} penalty:{PEN} type:LEFT product:{PROD}bp".format(ID=id,SUBID=m.group("id"),PEN=m.group("penalty"),PROD=m.group("size"))+os.linesep
    output_handle.write(line)
    line = m.group("left")+os.linesep
    output_handle.write(line)
    line = ">{ID} primer3 {SUBID} penalty:{PEN} type:RIGHT product:{PROD}bp".format(ID=id,SUBID=m.group("id"),PEN=m.group("penalty"),PROD=m.group("size"))+os.linesep
    output_handle.write(line)
    line = m.group("right")+os.linesep
    output_handle.write(line)
output_handle.close()
'''
}

workflow {
  ref = Channel.fromPath(params.fasta)
  seq = Channel.of(params.targetseq)
  seq.view()
  seqkit_fetch_target(seq,ref)
  target = seqkit_fetch_target.out.fasta

  primer3_conf(ref,target)
  primer3_index(ref)
  primer3_calc(primer3_conf.out,primer3_index.out)
  primer3_results2fasta(primer3_calc.out)
}
