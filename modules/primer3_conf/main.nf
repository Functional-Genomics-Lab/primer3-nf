process primer3_conf {
    publishDir "results/${task.process}", overwrite:'true'
    cache 'deep'
    conda "seqkit"
    tag "$target.baseName"

    input:
    path target
    path fasta

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
