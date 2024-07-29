process seqkit_fetch_target {
    conda "seqkit"
    tag "$meta.id"

    input:
    tuple val(meta), path(seq_fasta)
    path fasta

    output:
    path "*_targets.fa" , emit:fasta
    path "*_targets.gtf" , emit:gtf

    shell:
    def prefix = task.ext.prefix ?: "${meta.id}"
    '''
    cat !{fasta} | seqkit locate -i --gtf -f !{seq_fasta} > !{meta.id}_targets.gtf

    seqkit subseq --gtf !{meta.id}_targets.gtf -u 50000 -d 50000 !{fasta} > !{meta.id}_targets.fa

    if [[ ! -s !{meta.id}_targets.gtf ]]
    then
    exit 7
    fi

    seqkit stat !{meta.id}_targets.gtf
    seqkit stat !{meta.id}_targets.fa
    '''
}
