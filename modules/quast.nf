process QUAST {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/assembly/${sample_id}/qc", mode: 'copy'

    conda "bioconda::quast=5.2.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a5/a515d04307ea3e0178af75132105cd36c87d0116c6f9daecf81650b973e870fd/data' :
        'community.wave.seqera.io/library/quast:5.3.0--755a216045b6dbdd' }"

    input:
    tuple val(sample_id), path(flye_assembly), path(polished_assembly)

    output:
    tuple val(sample_id), path("quast/*"), emit: report
    path("quast/report.html"), emit: html

    script:
    """
    quast.py \\
        ${flye_assembly} \\
        ${polished_assembly} \\
        -o quast \\
        --threads ${task.cpus} \\
        --min-contig 500 \\
        --labels "Flye,Flye+Medaka"
    """
}
