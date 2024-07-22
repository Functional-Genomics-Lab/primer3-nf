process seqkit_fetch_target {
    conda "seqkit"

    input:
    val seq
    path fasta

    output:
    path "${seq}_target.fa" , emit:fasta
    path "${seq}_target.gtf" , emit:gtf

    shell:
    '''
    echo ">seq
    !{seq}
    " > seq.fa

    seqkit locate -i --gtf -p "!{seq}" !{fasta} > !{seq}_target.gtf

    seqkit subseq --gtf !{seq}_target.gtf -u 50000 -d 50000 !{fasta} > !{seq}_target.fa

    if [[ ! -s !{seq}_target.gtf ]]
    then
    exit 7
    fi

    seqkit stat !{seq}_target.gtf
    seqkit stat !{seq}_target.fa
    '''
}
