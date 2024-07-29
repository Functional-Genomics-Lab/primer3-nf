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


include { BEDTOOLS_GETFASTA } from './modules/nf-core/bedtools/getfasta'

include { PRIMER3 } from './subworkflows/primer3'

workflow {
    // Pull raw sequences in the bed files from the reference genome
    sequences = BEDTOOLS_GETFASTA (
        ch_input,
        params.fasta
    ).fasta
        .splitFasta(file: true)
        .dump()

    // Run primer3 on the sequences
    PRIMER3 (
        sequences,
        Channel.fromPath(params.fasta),
    )
}
