process BUSCO {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample_id}/qc", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_busco/*"), emit: report
    path("${sample_id}_busco/*.json"), emit: json_report
    path("${sample_id}_busco/short_summary*.txt"), emit: summary

    script:
    """
    busco \\
        -i ${assembly} \\
        -o ${sample_id}_busco \\
        -m genome \\
        -l bacteria_odb10 \\
        --cpu ${task.cpus} \\
        --offline \\
        --download_path ${params.busco_db}
    """
}
