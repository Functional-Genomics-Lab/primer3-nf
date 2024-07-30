process primer3_calc {
    conda "primer3"
    publishDir "results/${task.process}", overwrite:'true'
    cache 'deep'
    tag "$conf.baseName"

    input:
    path conf
    path kmer_lists, stageAs: 'kmer_lists/*'

    output:
    path "*_primer3.txt"
    // TODO eval version

    shell:
    '''
    primer3_core !{conf} > !{conf.baseName}_primer3.txt
    '''
}
