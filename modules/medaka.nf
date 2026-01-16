process MEDAKA {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_polished.fasta"), emit: polished
    tuple val(sample_id), path("medaka/*"), emit: medaka_dir

    script:
    """
    medaka_consensus \\
        -i ${reads} \\
        -d ${assembly} \\
        -o medaka \\
        -t ${task.cpus} \\
        -m ${params.medaka_model}

    cp medaka/consensus.fasta ${sample_id}_polished.fasta
    """
}
