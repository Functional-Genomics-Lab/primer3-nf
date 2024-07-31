process primer3_results2fasta {
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
