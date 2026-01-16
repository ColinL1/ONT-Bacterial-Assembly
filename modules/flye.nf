process FLYE {
    tag "$sample_id"
    label 'process_high'
    errorStrategy  'ignore'
    publishDir "${params.outdir}/assembly/${sample_id}", mode: 'copy'

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
