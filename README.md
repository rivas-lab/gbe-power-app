# gbe-power-app

Web app for calculating GWAS power using empirical allele frequency estimates.

## Cloning

Use `git lfs clone https://github.com/rivas-lab/gbe-power-app.git` to pull in
the files tracked with LFS.

## Running the app

First install the GeneticsDesign package from Bioconductor to obtain the needed
dependencies: 
```
source("https://bioconductor.org/biocLite.R")
biocLite("GeneticsDesign")
```
Then install my version of "GeneticsDesign" in `data` using `R CMD install
data/GeneticsDesign_1.45.0.tar.gz`. Start RStudio and open `shinyapp/ui.R` and
click the "Run App" button above the file contents. You can use the arrow next
to the "Run App" button to choose whether to launch the app in RStudio or your
browser. Note that the app relies on data that is tracked with git LFS, so be
it might make sense to make sure all the LFS data has been pulled in using `git
lfs pull`.

## Pushing the app to shinyapps.io

Use 
```
library(rsconnect)
rsconnect::deployApp('path/to/your/app')
``` 
to push the app to the web. Note that you must install the GeneticsDesign
package using
```
library(devtools)
install_github("cdeboever3/GeneticsDesign")
```
for this to work.

## App description

### Design Summary Table

The design summary table tells you how many genes are powered at 0.8 given the
study design parameters. The gene in the "Gene" box is not used for this table.
Currently, the calculation is kind of slow, so it may take ~1 minute to
generate the table.
