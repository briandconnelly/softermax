## Resubmission
This is a resubmission. The following changes have been made to address
feedback:

- All instances of SoftMax Pro (a software name) have been single quoted
- A web reference to the software has been added in the package description
- Additionally, a web link to the software has been added to the package doc

This new version has been re-tested, and no new errors, warnings, or notes were found


## Test environments
- Local macOS Sierra install, R 3.4.1
- Linux 4.4.0-92-generic amd64 (travis-ci), R 3.3.3, 3.4.1, 2017-09-20 r73325
    - Details: https://travis-ci.org/briandconnelly/softermax/builds/277932066
- win-builder (R-release and R-devel)
    - Details: https://win-builder.r-project.org/6ddCCWG2zBfW/


## R CMD check results

0 ERRORs
0 WARNINGs
1 NOTE:

    * checking CRAN incoming feasibility ... NOTE
    Maintainer: 'Brian Connelly <bdc@bconnelly.net>'

    New submission

    Possibly mis-spelled words in DESCRIPTION:
      SoftMax (3:32, 4:73)
      microtiter (4:19)

This is indeed a new package submission. Those words are spelled properly.


## Downstream dependencies
This package has no downstream dependencies on CRAN

