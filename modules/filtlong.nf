process FILTLONG {
    tag "$sample_id"
    label 'process_low'
    publishDir "${params.outdir}/qc/filtered", mode: 'copy'

    conda "bioconda::filtlong=0.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/filtlong:0.2.1--h9a82719_0' :
        'biocontainers/filtlong:0.2.1--h9a82719_0' }"

    input:
    tuple val(sample_id), path(trimmed_reads)
    val genome_size

    output:
    tuple val(sample_id), path("${sample_id}_filtered.fastq.gz"), emit: filtered_reads

    script:
    def target_bases = genome_size * params.target_coverage * 1000000
    """
    filtlong \\
        --min_length ${params.min_length} \\
        --keep_percent ${params.keep_percent} \\
        --target_bases ${target_bases} \\
        --length_weight 10 \\
        --mean_q_weight 10 \\
        ${trimmed_reads} | gzip > ${sample_id}_filtered.fastq.gz
    """
}
