# softermax NEXT

* `read_softmax_xml`: Added `...` arguments, passed to `xml2::read_xml`
* `read_softmax_template` now has an `encoding` argument for specifying the file encoding. If `guess` is used, encoding is guessed.


# softermax 0.2.3

* Added `read_softmax5_template`
* Added `softermax`, `softermax.experiment`, `softermax.plate`, `softermax.note`, `softermax.wavelength`, `softermax.well`, `softermax.template` constructors
* Using new constructors in `read_softmax5_xml`, `read_softmax6_xml`, `read_softmax5_template`, and `read_softmax6_template`
* `as.data.frame` functions: ReadMode can now be factors (the default behavior) via `readModesAsFactors` argument
* `read_softmax6_template`: Sample field now always treated as character
* Removed forcats dependency for package lightness


# softermax 0.2.2

* Added `apply_template` to annotate read data with experiment information stored in plate templates
* Added ReadMode column to `as.data.frame` to better support multi-mode experiments
* Fixed issue with `as.data.frame` where row.names were being set
* `read_softmax6_template` no longer uses subset, which required NSE and produced warnings
* Removed magrittr from Imports. No longer exporting pipe, which hasn't been used for many versions.


# softermax 0.2.1

* Specific experiments, plates, etc. can now be accessed by name
* `as.data.frame` functions: column order change in resulting data frames
* `as.data.frame` functions: explicit `row.names` and `optional` parameters for compatability with generic
* `as.data.frame` functions: using rbind to combine dfs, removing dplyr dependency.
* Added `experiment_names` and `plate_names` functions to extract experiment names and plate names
* `read_softmax6_xml` now warns if experiment contains multiple plates with the same name
* Added `read_softmax_template` for importing plate templates
* Added support for experiment Notes in SMP5 files


# softermax 0.2.0

* `read_softmax_xml` now returns a softermax object, which maintains more of the original data and metadata
    * Added `as.data.frame` methods to coerce these objects to data frames
    * Removed `combine_plates` which formerly served a similar purpose
* `read_softmax_xml` automatically detects the version of the file given
* Added support for SoftmaxPro 5.4 XML files. Thanks to [Bryon Drown](https://github.com/bdrown) for providing sample files!


# softermax 0.1.0

* Added a `NEWS.md` file to track changes to the package.
