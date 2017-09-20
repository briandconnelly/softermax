## Test environments
- Local macOS Sierra install, R 3.4.1

## R CMD check results
There were no ERRORs. 

There was 1 WARNING:

    Rd files with duplicated alias 'softermax':
      ‘softermax-package.Rd’ ‘objects.Rd’

This package, softermax, also has a softermax function. Roxygen creates
"softermax" aliases for both. However, the correct pages appear for `?softermax`
and `package?softermax`.
                                                                                
## Downstream dependencies                                                      
This package has no downstream dependencies on CRAN
