include { seqkit_fetch_target } from "../../modules/seqkit_fetch_target"
include { primer3_conf } from "../../modules/primer3_conf/"
include { primer3_index } from "../../modules/primer3_index/"
include { primer3_calc } from "../../modules/primer3_calc/"
include { primer3_results2fasta } from "../../modules/primer3_results2fasta/"

workflow PRIMER3 {
  take:
  seq_fasta // [meta, fasta]
  ref // fasta

  main:
  seqkit_fetch_target(seq_fasta,ref)
  target = seqkit_fetch_target.out.fasta
        .splitFasta(file: true)


  primer3_conf(target,ref)
  primer3_index(ref)
  primer3_calc(primer3_conf.out,primer3_index.out)
  primer3_calc.out.dump()
  // TODO primer3_results2fasta(primer3_calc.out)

  // emit:
  // primer3_results2fasta.out
}
