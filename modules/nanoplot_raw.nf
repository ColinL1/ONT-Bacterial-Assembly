process NANOPLOT_RAW {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/qc/nanoplot_raw", mode: 'copy'

    conda "bioconda::nanoplot=1.42.0 kaleido-core=0.2.1=h3644ca4_0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoplot:1.46.1--pyhdfd78af_0' :
        'biocontainers/nanoplot:1.46.1--pyhdfd78af_0' }"

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
