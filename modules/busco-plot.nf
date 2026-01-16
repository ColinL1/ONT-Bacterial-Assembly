process BUSCO_PLOT {
    // tag "$sample_id"
    label 'process_high'
    publishDir "${params.outdir}/assembly/busco_summary", mode: 'copy'
    
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
