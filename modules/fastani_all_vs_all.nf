process FASTANI_ALL_VS_ALL {
    tag "ani_matrix"
    label 'process_medium'
    publishDir "${params.outdir}/comparative/ani", mode: 'copy'

    conda "bioconda::fastani=1.33"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastani:1.32--he1c1bb9_0' :
        'biocontainers/fastani:1.32--he1c1bb9_0' }"

    input:
    path(assemblies)

    output:
    path("ani_matrix.txt"), emit: ani_matrix
    path("ani_matrix.tsv"), emit: ani_matrix_tsv
    path("assembly_list.txt"), emit: assembly_list
    path("versions.yml"), emit: versions

    script:
    """
    # Create list of assemblies
    ls *.fasta > assembly_list.txt

    # Run FastANI all-vs-all
    fastANI \\
        --rl assembly_list.txt \\
        --ql assembly_list.txt \\
        -o ani_matrix.txt \\
        -t ${task.cpus} \\
        --matrix

    # Create more readable TSV format
    awk '{print \$1"\\t"\$2"\\t"\$3"\\t"\$4"\\t"\$5}' ani_matrix.txt > ani_matrix.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastani: \$(fastANI --version 2>&1 | sed 's/version //g')
    END_VERSIONS
    """
}
