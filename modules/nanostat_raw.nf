process NANOSTAT_RAW {
    tag "$sample_id"
    label 'process_low'
    publishDir "${params.outdir}/qc", mode: 'copy'

    conda "bioconda::nanostat=1.6.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanostat:1.6.0--pyhdfd78af_0' :
        'anand7899/nanostat:latest' }"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_raw_stats.txt"), emit: stats

    script:
    """
    NanoStat --fastq ${reads} \\
        --name ${sample_id}_raw_stats.txt \\
        -t ${task.cpus} \\
        > ${sample_id}_raw_stats.txt
    """
}
