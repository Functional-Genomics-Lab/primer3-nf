nextflow.enable.dsl=2

process primer3_index {
    conda "genometester4"
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"
    input:
      path fasta    
    output:
      tuple path("${fasta}.crispr.db"),path("${fasta}.crispr.db.header")
    shell:
      '''
      
      '''
}

process primer3_conf {
    conda "genometester4"
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"
    input:
      path fasta    
    output:
      tuple path("${fasta}.crispr.db"),path("${fasta}.crispr.db.header")
    shell:
      '''
      
      '''
}

process primer3_calc {
    conda "genometester4"
    publishDir "results/${task.process}",mode:'link',overwrite:'true'
    cache 'deep'
    tag "$fasta"
    input:
      path fasta    
    output:
      tuple path("${fasta}.crispr.db"),path("${fasta}.crispr.db.header")
    shell:
      '''
      
      '''
}



workflow {
  ref = channel.fromPath(params.genome)
  target = channel.fromPath(params.target)
   
}
