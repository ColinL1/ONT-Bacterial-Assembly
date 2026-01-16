
process KEGGDECODER {
    // tag "$sample_id"
    label 'process_low'
    publishDir "${params.outdir}/pathways/KEGG-DECODER_summary", mode: 'copy'
    
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
