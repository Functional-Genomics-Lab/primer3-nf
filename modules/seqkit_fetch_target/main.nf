process seqkit_fetch_target {
    conda "seqkit"

    input:
    tuple val(id), val(seq)
    path fasta

    output:
    path "${seq}_target.fa" , emit:fasta
    path "${seq}_target.gtf" , emit:gtf

    shell:
    '''
    echo ">!{id}
    !{seq}
    " > seq.fa

    seqkit locate -i --gtf -p "!{seq}" !{fasta} > !{id}_target.gtf

    seqkit subseq --gtf !{seq}_target.gtf -u 50000 -d 50000 !{fasta} > !{id}_target.fa

    if [[ ! -s !{id}_target.gtf ]]
    then
    exit 7
    fi

    seqkit stat !{id}_target.gtf
    seqkit stat !{id}_target.fa
    '''
}
