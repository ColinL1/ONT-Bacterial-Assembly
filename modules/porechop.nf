process PORECHOP {
    tag "$sample_id"
    label 'process_medium'
    // maxRetries 3
    // errorStrategy  { task.attempt <= maxRetries  ? 'retry' : 'ignore' } 
    errorStrategy  'ignore'
    publishDir "${params.outdir}/qc/trimmed", mode: 'copy'

    conda "bioconda::porechop_abi=0.5.0"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/porechop_abi:0.5.0post1--py310h275bdba_0'
        : 'biocontainers/porechop_abi:0.5.0post1--py310h275bdba_0'}"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed.fastq.gz"), emit: trimmed_reads

    script:
    """
    porechop_abi \\
        -i ${reads} \\
        -o ${sample_id}_trimmed.fastq.gz \\
        --threads ${task.cpus} \\
        -abi \\
        --discard_middle
    """
}
