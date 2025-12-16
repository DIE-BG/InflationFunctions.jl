# Change Log 

## [0.5.3] 2025-11

### Fixed
- Fixed constructor methods of the Gaussian smoothing functions. The `r` parameter is not necessarily an integer.
- Inflation functions in the `LegacyMai` submodule did not overload the `measure_name` and `measure_tag` needed for simulations. 
- Efficient MAI functions errored under certain parameter configurations due to the special segment algorithm implemented in the `get_segments` function. Defaults were added to ensure the normalization algorithm works for any quantile vector specification.  
- `InflationCoreMai` constructors were sorting in place the `CountryStructure` needed to instantiate the inflation function. This was an undesirable side effect. The private function `_historical_distr` was modified to create copies of the underlying data.  
- Removed the redefinition of `measure_name` to `InflationTotalCPI`.

## [0.5.2] 2025-10

### Fixed
- `InflationTrimmedMeanWeighted`: Removed thread-parallelism for Julia 1.12. Refactored and validated main constructor.
- `InflationTrimmedMeanEq`: Refactored and validated main constructor.

## [0.5.1] 2025-10

### Fixed
- `InflationFixedExclusionCPI`: The aggregate base index was not being used to compute the month-on-month inflation for the fixed-exclusion method.

## [0.5.0] 2025-10

### Added 
- Function `set_language!` to select from English and Spanish labels when calling `measure_name` on them.

### Changed
- Add restriction on the number of segments in MAI functions.
- Add new tests in runtests.jl to compare new code and legacy code for inflation MAI functions.
- Translate measures names.
- Add tag to every function script file.
- Add new tests to verify functionality of Gaussian Smoothing functions.
- Change name of MAI-F function to MAI-FG, and name to MAI-FP to MAI-F.