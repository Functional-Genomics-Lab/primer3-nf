process primer3_results2fasta {
    publishDir "results/${task.process}", overwrite:'true'
    cache 'deep'
    tag "$results.baseName"

    input:
    path results

    output:
    path "*.fa"

    script:
    """
    results2fasta.py ${results} ${results.baseName}.fa
    """
}
