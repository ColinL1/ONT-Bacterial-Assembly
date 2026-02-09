process ORTHOFINDER {
    tag "orthofinder_analysis"
    label 'process_high'
    publishDir "${params.outdir}/comparative/orthofinder", mode: 'copy'

    conda "bioconda::orthofinder=2.5.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/orthofinder:2.5.5--hdfd78af_2':
        'biocontainers/orthofinder:2.5.5--hdfd78af_2' }"

    input:
    path(proteomes)

    output:
    path("OrthoFinder/Results_*/"), emit: results
    path("OrthoFinder/Results_*/Orthogroups/Orthogroups.tsv"), emit: orthogroups
    path("OrthoFinder/Results_*/Comparative_Genomics_Statistics/"), emit: statistics, optional: true
    path("OrthoFinder/Results_*/Species_Tree/"), emit: species_tree, optional: true
    path("OrthoFinder/Results_*/Phylogenetic_Hierarchical_Orthogroups/"), emit: phylo_orthogroups, optional: true
    path("versions.yml"), emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    mkdir -p proteomes
    cp ${proteomes} proteomes/

    orthofinder \\
        -f proteomes \\
        -t ${task.cpus} \\
        -a ${task.cpus} \\
        -o OrthoFinder \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        orthofinder: \$(orthofinder -h | grep "OrthoFinder version" | sed 's/OrthoFinder version //')
    END_VERSIONS
    """
}
