process BAKTA {
    tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/annotation/${sample_id}", mode: 'copy'

    conda "bioconda::bakta=1.9.4"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/bakta:1.11.4--pyhdfd78af_0'
        : 'biocontainers/bakta:1.11.4--pyhdfd78af_0'}"

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