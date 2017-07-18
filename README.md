# gbe-power-app

Web app for calculating GWAS power using empirical allele frequency estimates.

## Cloning

Use `git lfs clone https://github.com/rivas-lab/gbe-power-app.git` to pull in
the files tracked with LFS.

## Running the app

First install the GeneticsDesign package in `data` using 
`R CMD install data/GeneticsDesign_1.45.0.tar.gz`. Start RStudio and open
`shinyapp/ui.R` and click the "Run App" button above the file contents. You can
use the arrow next to the "Run App" button to choose whether to launch the app
in RStudio or your browser. Note that the app relies on data that is tracked
with git LFS, so be it might make sense to make sure all the LFS data has been
pulled in using `git lfs pull`.
