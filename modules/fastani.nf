// ANI (Average Nucleotide Identity) comparison module for genome analysis

process FASTANI {
    tag "$meta.id"
    label 'process_medium'
    
    conda "bioconda::fastani=1.33"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastani:1.33--h9ee0642_0' :
        'staphb/fastani:latest' }"
    
    input:
    tuple val(meta), path(query)
    tuple val(meta2), path(reference)
    
    output:
    tuple val(meta), path("*.ani.txt"), emit: ani
    path "versions.yml"               , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fastANI \\
        -q ${query} \\
        -r ${reference} \\
        -o ${prefix}.ani.txt \\
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastani: \$(fastANI --version 2>&1 | sed 's/version //g')
    END_VERSIONS
    """
}

process SKANI {
    tag "$meta.id"
    label 'process_medium'
    
    conda "bioconda::skani=0.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastani:1.32--he1c1bb9_0' :
        'biocontainers/fastani:1.32--he1c1bb9_0' }"
    
    input:
    tuple val(meta), path(query)
    tuple val(meta2), path(reference)
    
    output:
    tuple val(meta), path("*.tsv"), emit: ani
    path "versions.yml"           , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    skani dist \\
        ${query} \\
        ${reference} \\
        -o ${prefix}.tsv \\
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        skani: \$(skani --version 2>&1 | sed 's/skani //g')
    END_VERSIONS
    """
}