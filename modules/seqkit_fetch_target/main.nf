process seqkit_fetch_target {
    conda "seqkit"
    tag "$meta.id"

    input:
    tuple val(meta), path(seq_fasta)
    path fasta

    output:
    path "${seq}_target.fa" , emit:fasta
    path "${seq}_target.gtf" , emit:gtf

    shell:
    def prefix = task.ext.prefix ?: "${meta.id}"
    '''
    cat !{fasta} | seqkit locate -i --gtf -f !{seq_fasta} > !{meta.id}_target.gtf

    seqkit subseq --gtf !{meta.id}_target.gtf -u 50000 -d 50000 !{fasta} > !{meta.id}_target.fa

    if [[ ! -s !{meta.id}_target.gtf ]]
    then
    exit 7
    fi

    seqkit stat !{meta.id}_target.gtf
    seqkit stat !{meta.id}_target.fa
    '''
}
