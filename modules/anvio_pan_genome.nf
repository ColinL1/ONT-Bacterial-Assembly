process ANVIO_PAN_GENOME {
    label 'process_high'
    publishDir "${params.outdir}/anvio/pangenome", mode: 'copy'

    input:
    path(genomes_storage)

    output:
    path("${params.project_name}-PAN.db"), emit: pan_db
    path("${params.project_name}/*"), emit: pangenome

    script:
    def project = params.project_name ?: "PANGENOME"
    """
    anvi-pan-genome \\
        -g ${genomes_storage} \\
        --project-name ${project} \\
        --num-threads ${task.cpus} \\
        --minbit ${params.minbit ?: 0.5} \\
        --mcl-inflation ${params.mcl_inflation ?: 10} \\
        --min-occurrence ${params.min_occurrence ?: 2} 
    """
}
