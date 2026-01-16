process ANVIO_GEN_CONTIGS_DATABASE {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/anvio/${sample_id}", mode: 'copy'

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
