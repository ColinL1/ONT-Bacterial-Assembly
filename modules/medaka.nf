process MEDAKA {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample_id}", mode: 'copy'

    conda "bioconda::medaka=1.12.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka:1.4.4--py38h130def0_0' :
        'biocontainers/medaka:1.4.4--py38h130def0_0' }"

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
