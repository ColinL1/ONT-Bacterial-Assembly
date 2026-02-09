
process KEGGDECODER {
    // tag "$sample_id"
    label 'process_low'
    publishDir "${params.outdir}/pathways/KEGG-DECODER_summary", mode: 'copy'

    conda "bioconda::kegg-decoder=1.3.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kegg-decoder:1.3.0--pyhdfd78af_0' :
        'fmalmeida/keggdecoder:latest' }"  

    input:
    path (sample_id)
    
    output:
    path "*.svg"
    path "kegg-decoder.list" 
    
    script:
    """
    cat *.txt > JOINT_REPORT.tsv

    KEGG-decoder -i JOINT_REPORT.tsv -o kegg-decoder.list --vizoption static
    """
}
