process QUAST {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/assembly/${sample_id}/qc", mode: 'copy'

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
