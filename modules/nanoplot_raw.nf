process NANOPLOT_RAW {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/qc/nanoplot_raw", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}"), emit: report
    path("${sample_id}/*.html"), emit: html

    script:
    """
    NanoPlot -t ${task.cpus} \\
        --fastq ${reads} \\
        --loglength \\
        --plots dot \\
        -o ${sample_id} \\
        --N50 \\
        --title "${sample_id} - Raw Reads"
    """
}
