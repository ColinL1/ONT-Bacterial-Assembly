process ANVIO_GEN_GENOMES_STORAGE {
    label 'process_medium'
    publishDir "${params.outdir}/anvio/pangenome", mode: 'copy'

    conda "bioconda::anvio=8.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anvio:8.0--pyh7cba7a3_1' :
        'meren/anvio:8' }"

    input:
    path(contigs_dbs)
    path(external_genomes)

    output:
    path("GENOMES.db"), emit: genomes_storage
    path("external-genomes.txt"), emit: external_genomes_file

    script:
    """
    anvi-gen-genomes-storage \\
        -e ${external_genomes} \\
        -o GENOMES.db
    """
}
