process BUSCO_PLOT {
    // tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/assembly/busco_summary", mode: 'copy'

    conda "bioconda::busco=5.7.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/c6/c607f319867d96a38c8502f751458aa78bbd18fe4c7c4fa6b9d8350e6ba11ebe/data'
        : 'community.wave.seqera.io/library/busco_sepp:f2dbc18a2f7a5b64'}"

    input:
    path json_files
    
    output:
    path "busco_summaries/*.png" 
    
    script:
    """
    mkdir busco_summaries
    mv *.json busco_summaries/
    busco --plot busco_summaries
    """
}
