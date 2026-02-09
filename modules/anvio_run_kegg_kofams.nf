process ANVIO_RUN_KEGG_KOFAMS {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/anvio/${sample_id}", mode: 'copy'

    conda "bioconda::anvio=8.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anvio:8.0--pyh7cba7a3_1' :
        'meren/anvio:8' }"

    input:
    tuple val(sample_id), path(contigs_db)

    output:
    tuple val(sample_id), path(contigs_db), emit: contigs_db

    script:
    """
    anvi-run-kegg-kofams \\
        -c ${contigs_db} \\
        --num-threads ${task.cpus} \\
        --just-do-it
    """
}
