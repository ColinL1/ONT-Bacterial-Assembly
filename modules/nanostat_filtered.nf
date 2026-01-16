process NANOSTAT_FILTERED {
    tag "$sample_id"
    label 'process_low'
    publishDir "${params.outdir}/qc", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_filtered_stats.txt"), emit: stats

    script:
    """
    NanoStat --fastq ${reads} \\
        --name ${sample_id}_filtered_stats.txt \\
        -t ${task.cpus} \\
        > ${sample_id}_filtered_stats.txt
    """
}
