# softermax NEXT

* `as.data.frame` functions: column order change in resulting data frames
* `as.data.frame` functions: explicit `row.names` and `optional` parameters for compatability with generic
* Added `experiment_names` and `plate_names` functions to extract experiment names and plate names
* `read_softmax6_xml` now warns if experiment contains multiple plates with the same name
* Added `as_tibble` methods to coerce data to [tibbles](http://tibble.tidyverse.org) (with optional nesting)


# softermax 0.2.0

* `read_softmax_xml` now returns a softermax object, which maintains more of the original data and metadata
    * Added `as.data.frame` methods to coerce these objects to data frames
    * Removed `combine_plates` which formerly served a similar purpose
* `read_softmax_xml` automatically detects the version of the file given
* Added support for SoftmaxPro 5.4 XML files. Thanks to [Bryon Drown](https://github.com/bdrown) for providing sample files!


# softermax 0.1.0

* Added a `NEWS.md` file to track changes to the package.
