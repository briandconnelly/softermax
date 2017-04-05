# softermax

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![BSD License](https://img.shields.io/badge/license-BSD-brightgreen.svg)](https://opensource.org/licenses/BSD-2-Clause)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/softermax)](https://cran.r-project.org/package=softermax)

Read microtiter plate data exported from [Molecular Devices](https://www.moleculardevices.com) [SoftMax Pro](https://www.moleculardevices.com/systems/microplate-readers/softmax-pro-7-software).


## Installation

softermax is not quite ready to be available on [CRAN](http://cran.r-project.org), but you can use [devtools](http://cran.r-project.org/web/packages/devtools/index.html) to install the current development version:

```r
    if(!require("devtools")) install.packages("devtools")
    devtools::install_github("briandconnelly/softermax")
```

## Usage

To start working with your plate data in R, we'll first export the data as an XML file from SoftMax Pro.

### Exporting Plate Data as XML

With your experiment file open, select **Export** from the Main Menu.

![](README-images/main_menu.png).

Now, from the Export dialog, select either a single plate (orange butterfly) or all of the plates (blue raindrop) from your experiment.
Then, select **XML** under *Output Format* (green ghost), and hit the **OK** button.

![](README-images/export_details.png)

Choose your file name, and you're all set.

### Importing Data into R

The `read_softmax_xml` function can read XML files exported by SoftMax Pro.
Just supply the name of the file that you saved.

```r
    library(softermax)

    d <- read_softmax_xml("mydata.xml")
```

The variable `d` is an object that contains information about your experiment.
Most importantly, `d$plates` is a list where each element is a data frame (actually a [tibble](https://cran.r-project.org/package=tibble)) with information about each well in that plate.


## Contributer Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms


## Disclaimer

This project and its author are not affiliated with [Molecular Devices, LLC](https://www.moleculardevices.com).
