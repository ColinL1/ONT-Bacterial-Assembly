process BAKTA {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/annotation/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}/*"), emit: annotation
    path("${sample_id}/${sample_id}.gbff"), emit: genbank
    path("${sample_id}/${sample_id}.gff3"), emit: gff
    tuple val(sample_id), path("${sample_id}/${sample_id}.faa"), emit: proteins
    path("${sample_id}/${sample_id}.tsv"), emit: tsv
    path("${sample_id}/${sample_id}.json"), emit: json

    script:
    """
    bakta \\
        --db ${params.bakta_db} \\
        --output ${sample_id} \\
        --prefix ${sample_id} \\
        --threads ${task.cpus} \\
        --verbose \\
        --keep-contig-headers \\
        --compliant \\
        ${assembly}
    """
}

// TODO: consider moving --compliant flag to params?