process ANVIO_GEN_GENOMES_STORAGE {
    label 'process_medium'
    publishDir "${params.outdir}/anvio/pangenome", mode: 'copy'

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
