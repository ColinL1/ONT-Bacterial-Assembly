process KOFAMSCAN {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/pathways/${sample_id}", mode: 'copy'

    conda "bioconda::kofamscan=1.3.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kofamscan:1.3.0--hdfd78af_2':
        'biocontainers/kofamscan:1.3.0--hdfd78af_2' }"

    input:
    tuple val(sample_id), path(faa)

    output:
    tuple val(faa.baseName), path ("${faa.baseName}_kofamscan_results.tsv"), emit: detail_tsv
    path ("${faa.baseName}_mapper.txt"), emit: mapper

    script:
    """
    exec_annotation \\
            -p ${params.ko_profiles} \\
            -k ${params.ko_list} \\
            -o ${faa.baseName}_kofamscan_results.tsv \\
            --cpu ${task.cpus} \\
            --format detail-tsv \\
            ${faa}

    # Convert to mapper format (only significant hits with *)
    ## awk -F'\\t' '\$1 == "*" {print \$2 "\\t" \$3}' ${faa.baseName}_kofamscan_results.tsv > ${faa.baseName}_mapper.txt
    awk -F'\\t' '\$1 == "*" {print \$2 "\\t" \$3}' ${faa.baseName}_kofamscan_results.tsv | \\
    awk -v prefix="${faa.baseName}-" '{sub(/^/, prefix); print}' > ${faa.baseName}_mapper.txt
    
    """
}



        