process FLYE {
    tag "$sample_id"
    label 'process_high'
    errorStrategy  'ignore'
    publishDir "${params.outdir}/assembly/${sample_id}", mode: 'copy'

    conda "bioconda::flye=2.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fa/fa1c1e961de38d24cf36c424a8f4a9920ddd07b63fdb4cfa51c9e3a593c3c979/data' :
        'community.wave.seqera.io/library/flye:2.9.5--d577924c8416ccd8' }"

    input:
    tuple val(sample_id), path(reads)
    val genome_size

    output:
    tuple val(sample_id), path("${sample_id}_flye.fasta"), emit: assembly
    tuple val(sample_id), path("flye/*"), emit: flye_dir
    path("flye/assembly_graph.gfa"), emit: graph

    script:
    """
    flye \\
        --nano-hq ${reads} \\
        --genome-size ${genome_size}m \\
        --threads ${task.cpus} \\
        --out-dir flye \\
        --iterations 6 \\
        --meta

    cp flye/assembly.fasta ${sample_id}_flye.fasta
    """
}
