#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
    Anvi'o Contigs Database Preparation Subworkflow
========================================================================================
    Prepares annotated contigs databases for pangenome analysis
    Creates contigs.db and runs HMM, Pfam, COG, and KEGG annotations
*/

// Import modules
include { ANVIO_GEN_CONTIGS_DATABASE } from '../modules/anvio_gen_contigs_database'
include { ANVIO_RUN_HMMS } from '../modules/anvio_run_hmms'
include { ANVIO_RUN_PFAMS } from '../modules/anvio_run_pfams'
include { ANVIO_RUN_NCBI_COGS } from '../modules/anvio_run_ncbi_cogs'
include { ANVIO_RUN_KEGG_KOFAMS } from '../modules/anvio_run_kegg_kofams'
include { ANVIO_GEN_GENOMES_STORAGE } from '../modules/anvio_gen_genomes_storage'
include { ANVIO_PAN_GENOME } from '../modules/anvio_pan_genome'

workflow PREPARE_ANVIO_CONTIGS {
    take:
    assemblies  // tuple(sample_id, assembly.fasta)
    
    main:
    // Generate contigs database
    ANVIO_GEN_CONTIGS_DATABASE(assemblies)
    
    // Run HMM annotation (COGs, SCGs, etc.)
    ANVIO_RUN_HMMS(ANVIO_GEN_CONTIGS_DATABASE.out.contigs_db)
    
    // Run Pfam annotation
    ANVIO_RUN_PFAMS(ANVIO_RUN_HMMS.out.contigs_db)

    // Run NCBI COG annotation
    ANVIO_RUN_NCBI_COGS(ANVIO_RUN_PFAMS.out.contigs_db)

    // Run KEGG KOfam annotation
    ANVIO_RUN_KEGG_KOFAMS(ANVIO_RUN_NCBI_COGS.out.contigs_db)

    // // Run NCBI COG annotation (optional - can be controlled via params)
    // ch_for_cogs = params.anvio_run_cogs ? ANVIO_RUN_PFAMS.out.contigs_db : ANVIO_RUN_PFAMS.out.contigs_db
    
    // if (params.anvio_run_cogs) {
    //     ANVIO_RUN_NCBI_COGS(ch_for_cogs)
    //     ch_for_kegg = ANVIO_RUN_NCBI_COGS.out.contigs_db
    // } else {
    //     ch_for_kegg = ch_for_cogs
    // }
    
    // // Run KEGG KOfam annotation (optional - can be controlled via params)
    // if (params.anvio_run_kegg) {
    //     ANVIO_RUN_KEGG_KOFAMS(ch_for_kegg)
    //     ch_final = ANVIO_RUN_KEGG_KOFAMS.out.contigs_db
    // } else {
    //     ch_final = ch_for_kegg
    // }
    
    // Collect all contigs databases and create external genomes file
    ANVIO_RUN_KEGG_KOFAMS.out.contigs_db
        .map { sample_id, db -> 
            def db_path = db.toString()
            "${sample_id}\t${db_path}"
        }
        .collectFile(name: 'external-genomes.txt', newLine: true, 
                     seed: "name\tcontigs_db_path",
                     storeDir: "${params.outdir}/anvio/pangenome")
        .set { ch_external_genomes }
    
    // Collect all contigs database files
    ANVIO_RUN_KEGG_KOFAMS.out.contigs_db
        .map { sample_id, db -> db }
        .collect()
        .set { ch_all_dbs }
    
    // Generate genomes storage
    ANVIO_GEN_GENOMES_STORAGE(
        ch_all_dbs,
        ch_external_genomes
    )
    
    // Run pangenome analysis
    ANVIO_PAN_GENOME(
        ANVIO_GEN_GENOMES_STORAGE.out.genomes_storage
    )
    
    emit:
    contigs_db = ANVIO_RUN_KEGG_KOFAMS.out.contigs_db
    genomes_storage = ANVIO_GEN_GENOMES_STORAGE.out.genomes_storage
    pan_db = ANVIO_PAN_GENOME.out.pan_db
    pangenome = ANVIO_PAN_GENOME.out.pangenome
}
