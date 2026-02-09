process ANVIO_PAN_GENOME {
    label 'process_high'
    publishDir "${params.outdir}/anvio/pangenome", mode: 'copy'

    conda "bioconda::anvio=8.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anvio:8.0--pyh7cba7a3_1' :
        'meren/anvio:8' }"

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
