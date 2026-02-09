process ANVIO_GEN_CONTIGS_DATABASE {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/anvio/${sample_id}", mode: 'copy'

    conda "bioconda::anvio=8.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anvio:8.0--pyh7cba7a3_1' :
        'meren/anvio:8' }"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}-contigs.db"), emit: contigs_db
    path("${sample_id}-contigs.db"), emit: db

    script:
    """
    anvi-gen-contigs-database \\
        -f ${assembly} \\
        -o ${sample_id}-contigs.db \\
        -n "${sample_id} contigs database" \\
        --num-threads ${task.cpus}
    """
}
