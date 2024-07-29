nextflow.enable.dsl=2

include { validateParameters; paramsHelp; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

// Print help message, supply typical command line usage for the pipeline
if (params.help) {
   log.info paramsHelp("nextflow run my_pipeline --input input_file.csv")
   exit 0
}

// Validate input parameters
// TODO validateParameters()

// Print summary of supplied parameters
log.info paramsSummaryLog(workflow)

// Create a new channel of metadata from a sample sheet passed to the pipeline through the --input parameter
ch_input = Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))

include { seqkit_fetch_target } from "./modules/seqkit_fetch_target"
include { primer3_conf } from "./modules/primer3_conf/"
include { primer3_index } from "./modules/primer3_index/"
include { primer3_calc } from "./modules/primer3_calc/"
include { primer3_results2fasta } from "./modules/primer3_results2fasta/"

workflow {
  // Read in bed file(s)
  // Pull raw sequences in the bed files from the reference genome
  // Run primer3 on the sequences
  PRIMER3 (
    Channel.of(params.targetseq),
    Channel.fromPath(params.fasta),
  )
}
workflow PRIMER3 {
  take:
  seq
  ref

  main:
  seq.view()
  seqkit_fetch_target(seq,ref)
  target = seqkit_fetch_target.out.fasta

  primer3_conf(target,ref)
  primer3_index(ref)
  primer3_calc(primer3_conf.out,primer3_index.out)
  primer3_results2fasta(primer3_calc.out)

  emit:
  primer3_results2fasta.out
}
