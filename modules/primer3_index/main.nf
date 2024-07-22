process primer3_index {
    conda "genometester4"
    publishDir "results/${task.process}",overwrite:'true'
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
