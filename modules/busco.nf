process BUSCO {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample_id}/qc", mode: 'copy'

    conda "bioconda::busco=5.7.1"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/41/4137d65ab5b90d2ae4fa9d3e0e8294ddccc287e53ca653bb3c63b8fdb03e882f/data'
        : 'community.wave.seqera.io/library/busco:6.0.0--a9a1426105f81165'}"
    // Note: one test had to be disabled when switching to Busco 6.0.0, cf https://github.com/nf-core/modules/pull/8781/files
    // Try to restore it when upgrading Busco to a later version

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
