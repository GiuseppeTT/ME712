# ME712

## Overview
This repository comprehends the project developed by the students Aline Shikasho (ME812), Beatriz Messias (ME712) and Giuseppe Tomio (ME712) under the supervision of Professor Larissa Matos. The project consists of making a statistical analysis for the PhD candidate Daniel Teixeira, from Institute of Biology - University of Campinas. He studied the impact of the supression of genes RAG1 and RAG2 in the health condition of rats infected with Oropouche.

## Data, report and presentation slides
Currently, the data, report and presentation slides are not publicly available as they are part of an unpublished research.

## Dependencies
If you can't run the analysis due to some missing R packages, consider running the following command on shell

```r
make dependencies
```

Alternatively, you can run `renv::restore()` on a R console. You may need to install `renv` package first by `install.packages("renv")`.


## How to run
You can reproduce the analysis by running the following command on shell:

```r
make drake
```

This will run all the necessary steps of the [drake](https://github.com/ropensci/drake) workflow (e.g., clean data, run models, generate report). 
