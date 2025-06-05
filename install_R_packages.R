# Configure BioCManager to use Posit Package Manager:
options(BioC_mirror = "https://packagemanager.posit.co/bioconductor/latest")
options(BIOCONDUCTOR_CONFIG_FILE = "https://packagemanager.posit.co/bioconductor/latest/config.yaml")

# Set the Bioconductor version to prevent defaulting to a newer version:
Sys.setenv("R_BIOC_VERSION" = "3.19")

# Configure a CRAN snapshot compatible with Bioconductor 3.19:
# NOTE: using PPM instead of CRAN as described here: https://github.com/r-lib/pak/issues/623
options(repos = c(PPM = "https://packagemanager.posit.co/cran/__linux__/focal/2024-10-30")) # replace this with options(repos = c(PPM = "https://packagemanager.posit.co/cran/2024-10-30")) if you want to replaicate env on MAC

# Install pak
install.packages("pak")

# Install all other packages with pak
pak::pkg_install(c(
  # CRAN 
  "SeuratObject@4.1.3",
  "Seurat@4.3.0",
  "Signac@1.11.0",
  "harmony@1.2.0",
  "qs",
  "argparse",
  "hdf5r",
  "openxlsx2",
  "tidyverse@2.0.0",
  "doParallel@1.0.17",
  "magick",
  "ggh4x",
  "qlcMatrix@0.9.8",
  "ggsignif@0.6.4",
  
  # Bioconductor packages
  "bioc::BayesSpace@1.14.0",
  "bioc::MAST@1.30.0",
  "bioc::DESeq2@1.44.0",
  "bioc::scDblFinder@1.18.0",
  "bioc::glmGamPoi@1.16.0",
  "bioc::clusterProfiler@4.12.6",
  "bioc::org.Hs.eg.db@3.19.1",
  "bioc::biovizBase@1.52.0",
  "bioc::EnsDb.Hsapiens.v86@2.99.0",
  "bioc::BSgenome.Hsapiens.UCSC.hg38@1.4.5",
  "bioc::chromVAR@1.26.0",
  "bioc::JASPAR2020@0.99.10",

  # GitHub packages
  "lme4/lme4@bfd7a44d0a718fff090412871504858559a0829f",
  "immunogenomics/presto@1.0.0",
  "quadbio/Pando@v1.0.4"
  ))


# Clean up
pak::pak_cleanup(force = TRUE)
