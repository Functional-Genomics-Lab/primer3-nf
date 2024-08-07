process primer3_conf {
    conda "seqkit"
    tag "${target.baseName.replaceFirst(/\.primer3/, '')}"

    input:
    path target
    path fasta

    output:
    path "*.primer3.conf"

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

    # The while loop
    echo "SEQUENCE_ID=$(seqkit fx2tab !{target} | cut -f 1)
    TARGET=100,$($len - 200)
    SEQUENCE=$(seqkit fx2tab !{target} | cut -f 2)
    PRIMER_PRODUCT_SIZE_RANGE=$($len - 200)-$len
    # make_input_file2.pl
    PRIMER_NUM_RETURN=5
    PRIMER_OPT_SIZE=20
    PRIMER_MIN_SIZE=18
    PRIMER_MAX_SIZE=25
    PRIMER_OPT_TM=60.0
    PRIMER_MIN_TM=57.0
    PRIMER_MAX_TM=63.0
    PRIMER_MAX_DIFF_TM=2
    PRIMER_MIN_GC=40.0
    PRIMER_MAX_GC=60.0
    PRIMER_MAX_POLY_X=5
    PRIMER_SALT_CONC=50.0
    PRIMER_DNA_CONC=50.0
    PRIMER_NUM_NS_ACCEPTED=0
    PRIMER_MAX_END_STABILITY=9
    PRIMER_SELF_ANY=8
    PRIMER_SELF_END=3

    PRIMER_MASK_KMERLIST_PREFIX=!{fasta}
    PRIMER_MASK_KMERLIST_PATH=./kmer_lists/
    =" > !{target.baseName}.primer3.conf
    '''
}
