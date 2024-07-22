process primer3_calc {
    conda "primer3"
    publishDir "results/${task.process}", overwrite:'true'
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
