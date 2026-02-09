#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
    Comparative Genomics Subworkflow
========================================================================================
    Comparative genomics analysis including:
    - Average Nucleotide Identity (ANI) calculation with FastANI
    - Ortholog clustering and pangenome analysis with OrthoFinder
    - Core/accessory genome identification
    - Phylogenomic tree construction
========================================================================================
*/

// Import modules
include { FASTANI_ALL_VS_ALL } from '../modules/fastani_all_vs_all'
include { ORTHOFINDER } from '../modules/orthofinder'
include { PANGENOME_SUMMARY } from '../modules/pangenome_summary'

workflow COMPARATIVE_GENOMICS {
    take:
    assemblies  // channel: path(assembly files)
    proteins    // channel: path(protein .faa files)
    
    main:
    
    // Channel for versions
    ch_versions = Channel.empty()
    
    // Step 1: Calculate ANI (Average Nucleotide Identity)
    // ANI >95% indicates same species
    FASTANI_ALL_VS_ALL(
        assemblies.map { sample_id, path -> path }.collect()
    )
    ch_versions = ch_versions.mix(FASTANI_ALL_VS_ALL.out.versions)
    
    // Step 2: Run OrthoFinder for ortholog clustering and pangenome analysis
    // This identifies core genes, accessory genes, and unique genes
    ORTHOFINDER(
        proteins.map { sample_id, path -> path }.collect()
    )
    ch_versions = ch_versions.mix(ORTHOFINDER.out.versions)
    
    // Step 3: Analyze pangenome (core/accessory/unique genes)
    // Count the number of genomes for statistics
    genome_count = proteins.count()
    
    PANGENOME_SUMMARY(
        ORTHOFINDER.out.orthogroups,
        ORTHOFINDER.out.statistics,
        genome_count
    )
    
    emit:
    // ANI outputs
    ani_matrix = FASTANI_ALL_VS_ALL.out.ani_matrix
    ani_tsv = FASTANI_ALL_VS_ALL.out.ani_matrix_tsv
    
    // OrthoFinder outputs
    orthofinder_results = ORTHOFINDER.out.results
    orthogroups = ORTHOFINDER.out.orthogroups
    species_tree = ORTHOFINDER.out.species_tree
    
    // Pangenome outputs
    pangenome_summary = PANGENOME_SUMMARY.out.summary
    core_genes = PANGENOME_SUMMARY.out.core_genes
    accessory_genes = PANGENOME_SUMMARY.out.accessory_genes
    unique_genes = PANGENOME_SUMMARY.out.unique_genes
    pangenome_stats = PANGENOME_SUMMARY.out.stats
    
    versions = ch_versions
}
