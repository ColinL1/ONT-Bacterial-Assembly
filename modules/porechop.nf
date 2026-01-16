process PORECHOP {
    tag "$sample_id"
    label 'process_medium'
    // maxRetries 3
    // errorStrategy  { task.attempt <= maxRetries  ? 'retry' : 'ignore' } 
    errorStrategy  'ignore'
    publishDir "${params.outdir}/qc/trimmed", mode: 'copy'

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
