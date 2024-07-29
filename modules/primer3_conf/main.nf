process primer3_conf {
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"

    input:
    path target
    path fasta // TODO Cut this out

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

    echo "SEQUENCE_ID=example
    SEQUENCE_TEMPLATE=GTAGTCAGTAGACNATGACNACTGACGATGCAGACNACACACACACACACAGCACACAGGTATTAGTGGGCCATTCGATCCCGACCCAAATCGATAGCTACGATGACG
    SEQUENCE_TARGET=37,21
    PRIMER_TASK=generic
    PRIMER_PICK_LEFT_PRIMER=1
    PRIMER_PICK_INTERNAL_OLIGO=1
    PRIMER_PICK_RIGHT_PRIMER=1
    PRIMER_OPT_SIZE=18
    PRIMER_MIN_SIZE=15
    PRIMER_MAX_SIZE=21
    PRIMER_MAX_NS_ACCEPTED=1
    PRIMER_PRODUCT_SIZE_RANGE=75-100
    P3_FILE_FLAG=1
    SEQUENCE_INTERNAL_EXCLUDED_REGION=37,21
    PRIMER_EXPLAIN_FLAG=1
    =" > custom_primer3.conf
    '''
}
