process PANGENOME_SUMMARY {
    tag "pangenome_analysis"
    label 'process_low'
    publishDir "${params.outdir}/comparative/pangenome", mode: 'copy'

    conda "conda-forge::python=3.11 conda-forge::pandas=2.1.4 conda-forge::matplotlib=3.8.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-f42a44964bca5225c7860882e231a7b5488b5485:47ef981087c59f79fdbcab4d9d7316e9005428b2-0' :
        'erenlu/mulled-pca-viz:v1.0' }"

    input:
    path(orthogroups)
    path(statistics_dir)
    val(genome_count)

    output:
    path("pangenome_summary.txt"), emit: summary
    path("core_genes.txt"), emit: core_genes, optional: true
    path("accessory_genes.txt"), emit: accessory_genes, optional: true
    path("unique_genes.txt"), emit: unique_genes, optional: true
    path("pangenome_stats.tsv"), emit: stats

    script:
    """
    #!/usr/bin/env python3
    import pandas as pd
    import os

    # Read orthogroups
    og_df = pd.read_csv('${orthogroups}', sep='\\t')
    
    # Calculate pangenome statistics
    total_orthogroups = len(og_df)
    genomes = [col for col in og_df.columns if col != 'Orthogroup']
    n_genomes = len(genomes)
    
    # Identify core, accessory, and unique genes
    core_genes = []
    accessory_genes = []
    unique_genes = []
    
    for idx, row in og_df.iterrows():
        og_name = row['Orthogroup']
        present_in = sum([1 for g in genomes if pd.notna(row[g]) and row[g] != ''])
        
        if present_in == n_genomes:
            core_genes.append(og_name)
        elif present_in == 1:
            unique_genes.append(og_name)
        else:
            accessory_genes.append(og_name)
    
    # Write summary
    with open('pangenome_summary.txt', 'w') as f:
        f.write("=" * 60 + "\\n")
        f.write("Pangenome Analysis Summary\\n")
        f.write("=" * 60 + "\\n\\n")
        f.write(f"Number of genomes: {n_genomes}\\n")
        f.write(f"Total orthogroups: {total_orthogroups}\\n\\n")
        f.write(f"Core genes (present in all {n_genomes} genomes): {len(core_genes)}\\n")
        f.write(f"Accessory genes (present in 2-{n_genomes-1} genomes): {len(accessory_genes)}\\n")
        f.write(f"Unique genes (present in only 1 genome): {len(unique_genes)}\\n\\n")
        f.write(f"Core genome: {len(core_genes)/total_orthogroups*100:.1f}%\\n")
        f.write(f"Accessory genome: {len(accessory_genes)/total_orthogroups*100:.1f}%\\n")
        f.write(f"Unique genes: {len(unique_genes)/total_orthogroups*100:.1f}%\\n")
    
    # Write gene lists
    with open('core_genes.txt', 'w') as f:
        f.write("\\n".join(core_genes))
    
    with open('accessory_genes.txt', 'w') as f:
        f.write("\\n".join(accessory_genes))
    
    with open('unique_genes.txt', 'w') as f:
        f.write("\\n".join(unique_genes))
    
    # Write stats table
    stats_df = pd.DataFrame({
        'Category': ['Core genes', 'Accessory genes', 'Unique genes', 'Total orthogroups'],
        'Count': [len(core_genes), len(accessory_genes), len(unique_genes), total_orthogroups],
        'Percentage': [
            len(core_genes)/total_orthogroups*100,
            len(accessory_genes)/total_orthogroups*100,
            len(unique_genes)/total_orthogroups*100,
            100.0
        ]
    })
    stats_df.to_csv('pangenome_stats.tsv', sep='\\t', index=False)
    
    print("Pangenome analysis complete")
    """
}
