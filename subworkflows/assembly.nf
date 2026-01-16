#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
    Assembly Subworkflow
========================================================================================
    De novo assembly with Flye, polishing with Medaka, and QC
*/

// Import modules
include { FLYE } from '../modules/flye'
include { MEDAKA } from '../modules/medaka'
include { QUAST } from '../modules/quast'
include { BUSCO } from '../modules/busco'

workflow ASSEMBLY_WORKFLOW {
    take:
    filtered_reads  // tuple(sample_id, filtered.fastq.gz)
    genome_size     // val
    
    main:
    // De novo assembly
    FLYE(filtered_reads, genome_size)
    
    // Combine assembly with reads for polishing
    ch_polish = FLYE.out.assembly
        .join(filtered_reads)
    
    // Polish with Medaka
    MEDAKA(ch_polish)
    
    // Combine assemblies for QUAST
    ch_quast = FLYE.out.assembly
        .join(MEDAKA.out.polished)
    
    // Assembly QC
    QUAST(ch_quast)
    BUSCO(MEDAKA.out.polished)
    
    emit:
    polished_assembly = MEDAKA.out.polished
    flye_assembly = FLYE.out.assembly
    assembly_graph = FLYE.out.graph
    quast_report = QUAST.out.report
    busco_report = BUSCO.out.report
    busco_j_report = BUSCO.out.json_report
}
