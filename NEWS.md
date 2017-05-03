# softermax 0.2.0

* `read_softmax_xml` now returns a softermax object, which maintains more of the original data and metadata
    * Added `as.data.frame` methods to coerce these objects to data frames
    * Removed `combine_plates` which formerly served a similar purpose
* `read_softmax_xml` automatically detects the version of the file given
* Added support for SoftmaxPro 5.4 XML files. Thanks to [Bryon Drown](https://github.com/bdrown) for providing sample files!


# softermax 0.1.0

* Added a `NEWS.md` file to track changes to the package.



