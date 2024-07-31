process primer3_calc {
    conda "primer3"
    tag "${conf.baseName.replaceFirst(/\.primer3\$/, '')}"

    input:
    path conf
    path kmer_lists, stageAs: 'kmer_lists/*'

    output:
    path "*.txt"
    // TODO eval version

    shell:
    '''
    primer3_core !{conf} > !{conf.baseName}.txt
    '''
}
