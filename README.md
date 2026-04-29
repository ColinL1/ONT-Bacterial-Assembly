# ONT-Bacterial-Assembly: Bacterial Genome Analysis Pipeline

[![DOI](https://zenodo.org/badge/REPOSITORY_ID.svg)](https://zenodo.org/badge/latestdoi/REPOSITORY_ID)

A Nextflow DSL2 pipeline for quality control, assembly, annotation, and comparative genomics of bacterial genomes from Nanopore sequencing data.

## Pipeline Overview
This pipeline performs:

1. **Quality Control** - Raw data assessment with NanoPlot/NanoStat and read filtering with Filtlong
2. **Assembly** - De novo assembly with Flye and polishing with Medaka
3. **Assembly QC** - Quality assessment with QUAST and completeness check with BUSCO
4. **Annotation** - Taxon-independent functional annotation with Bakta and KEGG ortholog annotation with KOfamscan
5. **Pathway Analysis** - KEGG pathway reconstruction with KEGG-decoder across all samples
6. **Comparative Genomics** - Average Nucleotide Identity (ANI) analysis, ortholog clustering, and pangenome analysis
7. **Anvi'o Pangenome** (optional) - Preparation of annotated contigs databases for interactive pangenome visualization

---
> **Upcoming:** 
> - Switch to nf-core modules
> - Multiqc report creation
> - Input through spreadsheet with support to specific groups comparsion

---
<!-- ## Directory Structure
```
ONT-Bacterial-Assembly/
├── main.nf                           # Main pipeline workflow
├── nextflow.config                   # Configuration file
├── binac2.config                     # BinAC2 cluster configuration
├── modules/                          # Process modules
│   ├── nanoplot_raw.nf               # Raw read QC
│   ├── nanostat_raw.nf               # Raw read statistics
│   ├── porechop.nf                   # Adapter trimming (optional)
│   ├── filtlong.nf                   # Read filtering by length/quality
│   ├── nanoplot_filtered.nf          # Filtered read QC
│   ├── nanostat_filtered.nf          # Filtered read statistics
│   ├── flye.nf                       # De novo assembly
│   ├── medaka.nf                     # Assembly polishing
│   ├── quast.nf                      # Assembly quality assessment
│   ├── busco.nf                      # Assembly completeness
│   ├── busco-plot.nf                 # BUSCO summary visualization
│   ├── bakta.nf                      # Genome annotation
│   ├── kofamscan.nf                  # KEGG ortholog annotation
│   ├── keggdecoder.nf                # KEGG pathway analysis
│   ├── fastani.nf                    # ANI calculation
│   ├── fastani_all_vs_all.nf         # Pairwise ANI matrix
│   ├── orthofinder.nf                # Ortholog clustering
│   ├── pangenome_summary.nf          # Pangenome statistics
│   ├── anvio_gen_contigs_database.nf # Anvi'o contigs database
│   ├── anvio_run_hmms.nf             # Anvi'o HMM annotation
│   ├── anvio_run_pfams.nf            # Anvi'o Pfam annotation
│   ├── anvio_run_ncbi_cogs.nf        # Anvi'o COG annotation
│   ├── anvio_run_kegg_kofams.nf      # Anvi'o KEGG annotation
│   ├── anvio_gen_genomes_storage.nf  # Anvi'o genomes storage
│   └── anvio_pan_genome.nf           # Anvi'o pangenome analysis
├── subworkflows/                     # Workflow modules
│   ├── qc.nf                         # Quality control workflow
│   ├── assembly.nf                   # Assembly workflow
│   ├── annotation.nf                 # Annotation workflow
│   ├── comparative_genomics.nf       # Comparative genomics workflow
│   └── prepare_anvio_contigs.nf      # Anvi'o pangenome workflow
└── input/                            # Place your .fastq.gz files here
``` -->
---

### Prerequisites

#### Software Requirements

- Nextflow (>=23.04.0)
- One of: Conda, Docker, Singularity, or Apptainer

#### Required Tools

**Core Pipeline:**
- NanoPlot - Read quality visualization
- NanoStat - Read statistics
- Porechop_ABI - Adapter trimming (optional, currently disabled)
- Filtlong - Read length/quality filtering
- Flye - De novo assembly
- Medaka - Assembly polishing
- QUAST - Assembly quality assessment
- BUSCO - Genome completeness assessment
- Bakta - Genome annotation

**Functional Annotation:**
- KOfamscan - KEGG ortholog annotation
- KEGG-decoder - KEGG pathway visualization

**Comparative Genomics:**
- FastANI - Average Nucleotide Identity calculation
- OrthoFinder - Ortholog clustering and phylogenomics

**Anvi'o Pangenome (optional):**
- Anvi'o - Interactive pangenome analysis platform (requires separate conda environment)

#### Database Setup

**BUSCO Database** (automatically downloaded on first run):
```bash
busco --download bacteria_odb10
```

**Bakta Database** (required - must be downloaded):
```bash
# Download full Bakta database (~30 GB)
bakta_db download --output /path/to/bakta_db --type full

# Set in nextflow.config
params.bakta_db = "/path/to/bakta_db"
```

**KOfamscan Database** (required for KEGG annotation):
```bash
# Download KOfam profiles and KO list
wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz
wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz
gunzip ko_list.gz
tar xzf profiles.tar.gz

# Set in nextflow.config
params.ko_list = "/path/to/kofamscan/ko_list"
params.ko_profiles = "/path/to/kofamscan/profiles/"
```

**Anvi'o Databases** (optional, required if `prepare_anvio_pangenome = true`):
```bash
# After installing Anvi'o, set up databases
anvi-setup-ncbi-cogs
anvi-setup-pfams
anvi-setup-kegg-kofams
```

<!--
## Detailed Workflow

The pipeline consists of seven main stages that process bacterial genomes from raw Nanopore reads to comprehensive comparative genomics:

 ### 1. Quality Control (QC_WORKFLOW)
- **NanoPlot/NanoStat (Raw)**: Generate quality reports and statistics for raw reads
- **Porechop**: Adapter trimming (currently disabled in workflow, can be re-enabled if needed)
- **Filtlong**: Filter reads based on length and quality to achieve target coverage
  - Minimum length: 1000 bp (default)
  - Target coverage: 100x (default)
  - Keep percentage: 90% (default)
- **NanoPlot/NanoStat (Filtered)**: Quality assessment of filtered reads

### 2. Assembly (ASSEMBLY_WORKFLOW)
- **Flye**: De novo assembly using long-read overlap-layout-consensus algorithm
- **Medaka**: Polish assembly using neural network-based consensus calling
- **QUAST**: Assess assembly quality (N50, L50, contiguity, etc.)
- **BUSCO**: Evaluate genome completeness using single-copy ortholog database

### 3. Annotation (ANNOTATION_WORKFLOW)
- **Bakta**: Comprehensive genome annotation
  - Identifies coding sequences (CDS)
  - Annotates tRNA, rRNA, ncRNA
  - Functional annotation via multiple databases
  - Outputs: GFF3, GenBank, FASTA formats
- **KOfamscan**: KEGG ortholog (KO) annotation
  - Assigns KO identifiers to predicted proteins
  - Enables pathway reconstruction

### 4. Pathway Analysis
- **KEGG-decoder**: Metabolic pathway reconstruction across all samples
  - Visualizes pathway completeness
  - Generates heatmaps and summary statistics
  - Identifies functional differences between genomes

### 5. Comparative Genomics (COMPARATIVE_GENOMICS)
- **FastANI**: Calculate Average Nucleotide Identity (ANI)
  - All-vs-all pairwise comparisons
  - Species delineation (ANI >95% = same species)
  - Output: ANI matrix
- **OrthoFinder**: Ortholog clustering and phylogenomics
  - Identifies orthogroups (sets of orthologous genes)
  - Constructs species phylogenetic tree
  - Gene tree inference
- **Pangenome Summary**: Analyze core and accessory genome
  - Core genes: present in all genomes
  - Accessory genes: present in some genomes
  - Unique genes: specific to individual genomes
  - Generates statistics and gene lists

### 6. BUSCO Summary Visualization
- **BUSCO Plot**: Generate combined completeness plot for all samples
  - Visual comparison of genome completeness across all assemblies

### 7. Anvi'o Pangenome (Optional)
Prepares interactive pangenome databases for visualization in Anvi'o interface:
- **anvi-gen-contigs-database**: Create contigs database for each genome
- **anvi-run-hmms**: Annotate with HMM profiles (bacterial SCGs, Archaea SCGs, etc.)
- **anvi-run-pfams**: Add Pfam domain annotations
- **anvi-run-ncbi-cogs**: Add NCBI COG functional annotations
- **anvi-run-kegg-kofams**: Add KEGG ortholog annotations
- **anvi-gen-genomes-storage**: Combine all genomes into storage database
- **anvi-pan-genome**: Compute pangenome and gene clusters
  - Interactive visualization of gene presence/absence
  - Functional enrichment analysis
  - Phylogenomic context for gene clusters -->

## Usage

### Quick Start

1. Place your `.fastq.gz` files in the `input/` directory

2. Edit `nextflow.config` to set required database paths:
   ```groovy
   params {
       bakta_db = "/path/to/bakta_db"
       ko_list = "/path/to/kofamscan/ko_list"
       ko_profiles = "/path/to/kofamscan/profiles/"
       busco_db = "/path/to/busco_downloads"  // Optional, auto-downloads if not set
       prepare_anvio_pangenome = true  // Set to false to skip Anvi'o analysis
   }
   ```

3. Run the pipeline:
   ```bash
   nextflow run main.nf
   ```

### Using Conda

```bash
nextflow run main.nf -profile conda
```

### Using Singularity

```bash
nextflow run main.nf -profile singularity
```

### Using Docker

```bash
nextflow run main.nf -profile docker
```


### Custom Parameters

```bash
nextflow run main.nf \
    -profile conda
    --input /path/to/fastq \
    --outdir /path/to/results \
    --genome_size 4 \
    --target_coverage 100 \
    --max_cpus 16
```

## Parameters

### Main Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--input` | `./input` | Directory containing input .fastq.gz files |
| `--outdir` | `./results` | Output directory for results |
| `--genome_size` | `4` | Expected genome size in megabases |
| `--target_coverage` | `200` | Target coverage for read filtering |

### Quality Control Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--min_length` | `1000` | Minimum read length for Filtlong |
| `--keep_percent` | `90` | Percentage of reads to keep in Filtlong |

### Assembly Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--medaka_model` | `r1041_e82_400bps_sup_v5.2.0` | Medaka model for polishing (adjust based on basecaller) |

### Database Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--bakta_db` | Required | Path to Bakta database (REQUIRED) |
| `--busco_db` | See config | Path to BUSCO database |
| `--ko_list` | Required | Path to KOfamscan KO list file (REQUIRED) |
| `--ko_profiles` | Required | Path to KOfamscan profiles directory (REQUIRED) |

### Anvi'o Pangenome Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--prepare_anvio_pangenome` | `true` | Enable/disable Anvi'o pangenome preparation |
| `--project_name` | `VTK_ALL` | Name for your Anvi'o pangenome project |
| `--anvio_run_cogs` | `true` | Run NCBI COG annotation in Anvi'o |
| `--anvio_run_kegg` | `true` | Run KEGG KOfam annotation in Anvi'o |
| `--minbit` | `0.5` | Minimum alignment coverage for pangenome |
| `--mcl_inflation` | `10` | MCL inflation parameter for gene clustering |
| `--min_occurrence` | `2` | Minimum genomes a gene must occur in |

### Resource Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--max_cpus` | `260` | Maximum CPU cores per process |
| `--max_memory` | `950.GB` | Maximum memory per process |
| `--max_time` | `3.d` | Maximum time per process |

## Output Structure

```
results/
├── qc/
│   ├── nanoplot_raw/                 # Raw read QC reports
│   ├── nanoplot_filtered/            # Filtered read QC reports
│   ├── filtered/                     # Quality-filtered reads
│   ├── *_raw_stats.txt               # Raw read statistics
│   └── *_filtered_stats.txt          # Filtered read statistics
├── assembly/
│   └── [sample_id]/
│       ├── [sample_id]_flye.fasta    # Flye assembly
│       ├── [sample_id]_polished.fasta # Medaka-polished assembly
│       ├── flye/                     # Flye output directory
│       ├── medaka/                   # Medaka output directory
│       └── qc/
│           ├── quast/                # QUAST assembly QC
│           ├── [sample_id]_busco/    # BUSCO completeness per sample
│           └── busco_summary_plot/   # Combined BUSCO plot for all samples
├── annotation/
│   └── [sample_id]/
│       ├── [sample_id].gbff          # GenBank format annotation
│       ├── [sample_id].gff3          # GFF3 format annotation
│       ├── [sample_id].faa           # Protein sequences
│       ├── [sample_id].fna           # Nucleotide sequences
│       ├── [sample_id].tsv           # Annotation summary table
│       └── [sample_id].json          # JSON metadata
├── pathways/
│   ├── [sample_id]/
│   │   ├── [sample_id]_kofamscan_results.tsv  # KOfamscan detailed results
│   │   └── [sample_id]_mapper.txt              # KEGG mapper format
│   └── KEGG-DECODER_summary/
│       ├── kegg-decoder.list         # KEGG pathway summary list
│       └── *.svg                     # KEGG pathway visualizations
├── comparative_genomics/
│   ├── fastani/
│   │   ├── ani_matrix.txt            # ANI matrix (all-vs-all)
│   │   └── ani_matrix.tsv            # ANI matrix in TSV format
│   ├── orthofinder/
│   │   ├── Results_*/                # OrthoFinder results directory
│   │   │   ├── Orthogroups/
│   │   │   │   ├── Orthogroups.tsv   # Ortholog groups
│   │   │   │   └── Orthogroups.GeneCount.tsv
│   │   │   ├── Phylogenetic_Hierarchical_Orthogroups/
│   │   │   ├── Species_Tree/         # Phylogenomic tree
│   │   │   └── Comparative_Genomics_Statistics/
│   └── pangenome/
│       ├── pangenome_summary.txt     # Core/accessory/unique gene counts
│       ├── core_genes.txt            # Genes present in all genomes
│       ├── accessory_genes.txt       # Genes in some genomes
│       ├── unique_genes.txt          # Genes unique to single genomes
│       └── pangenome_stats.json      # Detailed statistics
├── anvio/                             # Optional, if prepare_anvio_pangenome = true
│   └── pangenome/
│       ├── [sample_id]/
│       │   └── CONTIGS.db            # Anvi'o contigs database per sample
│       ├── external-genomes.txt      # Genome manifest file
│       ├── [project_name]-GENOMES.db # Genomes storage
│       └── [project_name]-PAN/       # Pangenome database
│           └── PAN.db                # Interactive pangenome database
└── pipeline_info/
    ├── report.html                   # Execution report
    ├── timeline.html                 # Timeline visualization
    ├── trace.txt                     # Resource usage trace
    └── dag.svg                       # Pipeline DAG
```

## Example

Process multiple samples for comparative genomics:

```bash
# 1. Place your .fastq.gz files in input directory
cp /path/to/*.fastq.gz input/

# 2. Configure database paths in nextflow.config
# params.bakta_db = "/path/to/bakta_db"
# params.ko_list = "/path/to/kofamscan/ko_list"
# params.ko_profiles = "/path/to/kofamscan/profiles/"
# params.prepare_anvio_pangenome = true  # Enable Anvi'o analysis

# 3. Run pipeline with conda profile
nextflow run main.nf -profile conda

# 4. View results
tree results/

# 5. Key outputs to examine:
# - Assembly quality: results/assembly/[sample]/qc/quast/
# - Genome completeness: results/assembly/qc/busco_summary_plot/
# - Annotations: results/annotation/[sample]/
# - KEGG pathways: results/pathways/KEGG-DECODER_summary/
# - ANI matrix: results/comparative_genomics/fastani/ani_matrix.tsv
# - Pangenome stats: results/comparative_genomics/pangenome/
# - Anvi'o pangenome: results/anvio/pangenome/[project_name]-PAN/
```

## Resuming Failed Runs

Nextflow automatically caches completed processes. If a run fails, you can resume:

```bash
nextflow run main.nf -resume
```

## Troubleshooting

### Common Issues

1. **Required databases not set**
   - Bakta database: Set `params.bakta_db` in `nextflow.config` or use `--bakta_db` parameter
   - KOfamscan databases: Set `params.ko_list` and `params.ko_profiles` in config
   - BUSCO database: Auto-downloads or set `params.busco_db`

2. **Out of memory errors**
   - Adjust `--max_cpus` or `--max_memory` in config based on your system
   - Some processes (e.g., FLYE, OrthoFinder) are memory-intensive

3. **Anvi'o environment conflicts**
   - Anvi'o requires a separate conda environment
   - Configure in nextflow.config: `withName: 'ANVIO_.*' { conda = '/path/to/anvio-env' }`
   - Or disable Anvi'o analysis: `params.prepare_anvio_pangenome = false`

4. **Container not found**
   - Ensure Docker/Singularity/Apptainer is installed and running
   - Pull containers manually if needed
   - Or use conda profile: `nextflow run main.nf -profile conda`

5. **Medaka model mismatch**
   - Adjust `params.medaka_model` to match your basecaller version
   - See Medaka documentation for available models


## Citation

If you use this pipeline, please cite the tools:

**Core Tools:**
- **Nextflow**: Di Tommaso, P. et al. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316-319.
- **NanoPlot/NanoStat**: De Coster, W. et al. (2018). NanoPack: visualizing and processing long-read sequencing data. Bioinformatics, 34(15), 2666-2669.
- **Porechop_ABI**: Wick, R.R. et al. (2017). https://github.com/bonsai-team/Porechop_ABI
- **Filtlong**: Wick, R.R. https://github.com/rrwick/Filtlong
- **Flye**: Kolmogorov, M. et al. (2019). Assembly of long, error-prone reads using repeat graphs. Nature Biotechnology, 37(5), 540-546.
- **Medaka**: Oxford Nanopore Technologies. https://github.com/nanoporetech/medaka
- **QUAST**: Gurevich, A. et al. (2013). QUAST: quality assessment tool for genome assemblies. Bioinformatics, 29(8), 1072-1075.
- **BUSCO**: Manni, M. et al. (2021). BUSCO Update: Novel and Streamlined Workflows along with Broader and Deeper Phylogenetic Coverage for Scoring of Eukaryotic, Prokaryotic, and Viral Genomes. Molecular Biology and Evolution, 38(10), 4647-4654.
- **Bakta**: Schwengers, O. et al. (2021). Bakta: rapid and standardized annotation of bacterial genomes via alignment-free sequence identification. Microbial Genomics, 7(11).

**Functional Annotation:**
- **KOfamscan**: Aramaki, T. et al. (2020). KofamKOALA: KEGG Ortholog assignment based on profile HMM and adaptive score threshold. Bioinformatics, 36(7), 2251-2252.
- **KEGG-decoder**: Graham, E.D. et al. (2018). METABOLIC: high-throughput profiling of microbial genomes for functional traits, metabolism, biogeochemistry, and community-scale functional networks. https://github.com/bjtully/BioData/tree/master/KEGGDecoder

**Comparative Genomics:**
- **FastANI**: Jain, C. et al. (2018). High throughput ANI analysis of 90K prokaryotic genomes reveals clear species boundaries. Nature Communications, 9(1), 5114.
- **OrthoFinder**: Emms, D.M. & Kelly, S. (2019). OrthoFinder: phylogenetic orthology inference for comparative genomics. Genome Biology, 20(1), 238.

**Optional Tools:**
- **Anvi'o**: Eren, A.M. et al. (2015). Anvi'o: an advanced analysis and visualization platform for 'omics data. PeerJ, 3, e1319.
- **Anvi'o Pangenomics**: Delmont, T.O. & Eren, A.M. (2018). Linking pangenomes and metagenomes: the Prochlorococcus metapangenome. PeerJ, 6, e4320.

## License

This pipeline is open source and available under the MIT License.
