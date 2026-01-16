#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
    Annotation Subworkflow
========================================================================================
    Taxon-independent functional annotation with Bakta
*/

// Import modules
include { BAKTA } from '../modules/bakta'
include { KOFAMSCAN } from '../modules/kofamscan'

workflow ANNOTATION_WORKFLOW {
    take:
    polished_assembly  // tuple(sample_id, polished.fasta)
    
    main:
    // Functional annotation
    BAKTA(polished_assembly)
    KOFAMSCAN(BAKTA.out.proteins)
    
    emit:
    annotation = BAKTA.out.annotation
    genbank = BAKTA.out.genbank
    gff = BAKTA.out.gff
    proteins = BAKTA.out.proteins
    mapper = KOFAMSCAN.out.mapper
    kofam_tsv = KOFAMSCAN.out.detail_tsv
}
