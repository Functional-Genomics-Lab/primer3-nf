nextflow.enable.dsl=2

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

echo "SEQUENCE_ID=$(seqkit fx2tab | cut -f 1)
SEQUENCE_TEMPLATE=$(seqkit fx2tab | cut -f 2)
PRIMER_TASK=generic
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=0
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_OPT_SIZE=20
PRIMER_MIN_SIZE=18
PRIMER_MAX_SIZE=22
PRIMER_PRODUCT_SIZE_RANGE=75-150
PRIMER_EXPLAIN_FLAG=1
PRIMER_MASK_TEMPLATE=1
PRIMER_MASK_KMERLIST_PATH=./kmer_lists/
PRIMER_MASK_KMERLIST_PREFIX=!{fasta}
=" > custom_primer3.conf      
'''
}

process primer3_calc {
    conda "genometester4"
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"
    input:
      path fasta    
    output:
      tuple path("${fasta}.crispr.db"),path("${fasta}.crispr.db.header")
    shell:
      '''
      
      '''
}



workflow {
  ref = channel.fromPath(params.genome)
  target = channel.fromPath(params.target)

  primer3_conf(ref)
  primer3_index(ref)
}
