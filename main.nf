#!/usr/bin/env nextflow

/*
========================================================================================
    Bacterial Genome Analysis Pipeline - VTK2026
========================================================================================
    Quality Control, Assembly, and Annotation Pipeline for Nanopore Sequencing Data
----------------------------------------------------------------------------------------
*/

// Import subworkflows
include { QC_WORKFLOW } from './subworkflows/qc'
include { ASSEMBLY_WORKFLOW } from './subworkflows/assembly'
include { ANNOTATION_WORKFLOW } from './subworkflows/annotation'
include { PREPARE_ANVIO_CONTIGS } from './subworkflows/prepare_anvio_contigs'

// Import busco general QC
include { BUSCO_PLOT } from './modules/busco-plot'

// import module for functional annotation //TODO: move to separate workflow once better defined
include { KEGGDECODER } from './modules/keggdecoder'

/*
========================================================================================
    MAIN WORKFLOW
========================================================================================
*/

workflow {
    // Create input channel from fastq.gz files
    ch_input = channel
        .fromPath("${params.input}/*.fastq.gz")
        .map { file -> 
            def sample_id = file.baseName.replaceAll(/\.fastq$/, '')
            tuple(sample_id, file)
        }
    
    // Run quality control workflow
    QC_WORKFLOW(ch_input)

    // Run assembly workflow with filtered reads
    ASSEMBLY_WORKFLOW(
        QC_WORKFLOW.out.filtered_reads,
        params.genome_size
    )
    // Collect all BUSCO JSON files and create plot
    ASSEMBLY_WORKFLOW.out.busco_j_report
        | collect
        | BUSCO_PLOT

    // Run annotation workflow with polished assemblies
    ANNOTATION_WORKFLOW(
        ASSEMBLY_WORKFLOW.out.polished_assembly
    )
    ANNOTATION_WORKFLOW.out.mapper
    | collect
    | KEGGDECODER

    // Run 
    if (params.prepare_anvio_pangenome) {
        PREPARE_ANVIO_CONTIGS(
            ASSEMBLY_WORKFLOW.out.polished_assembly
        )
    }
}
