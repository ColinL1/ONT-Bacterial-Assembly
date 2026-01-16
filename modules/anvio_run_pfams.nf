process ANVIO_RUN_PFAMS {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/anvio/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(contigs_db)

    output:
    tuple val(sample_id), path(contigs_db), emit: contigs_db

    script:
    """
    anvi-run-pfams \\
        -c ${contigs_db} \\
        --num-threads ${task.cpus}
    """
}
