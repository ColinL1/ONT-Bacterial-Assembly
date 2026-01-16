#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
    QC Subworkflow
========================================================================================
    Quality control, adapter trimming, and read filtering
*/

// Import modules
include { NANOPLOT_RAW } from '../modules/nanoplot_raw'
include { NANOSTAT_RAW } from '../modules/nanostat_raw'
include { PORECHOP } from '../modules/porechop'
include { FILTLONG } from '../modules/filtlong'
include { NANOPLOT_FILTERED } from '../modules/nanoplot_filtered'
include { NANOSTAT_FILTERED } from '../modules/nanostat_filtered'

workflow QC_WORKFLOW {
    take:
    reads  // tuple(sample_id, fastq.gz)
    
    main:
    // Raw data QC
    NANOPLOT_RAW(reads)
    NANOSTAT_RAW(reads)
    
    // Adapter trimming
    // PORECHOP(reads)
    
    // Read filtering
    FILTLONG(
        // PORECHOP.out.trimmed_reads,
        reads,
        params.genome_size
    )
    
    // Post-filtering QC
    NANOPLOT_FILTERED(FILTLONG.out.filtered_reads)
    NANOSTAT_FILTERED(FILTLONG.out.filtered_reads)
    
    emit:
    filtered_reads = FILTLONG.out.filtered_reads
    raw_stats = NANOSTAT_RAW.out.stats
    filtered_stats = NANOSTAT_FILTERED.out.stats
}
