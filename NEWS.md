News
================

<!-- NEWS.md is generated from NEWS.Rmd. Please edit that file -->
inmetr 0.2.5.9999
=================

-   \[x\] add function to write csv files of station data.
-   \[ \] include `metadata_description()`.
-   \[ \] add function to provide daily data.

inmetr 0.2.5
============

-   \[x\] include metadata of 394 meteorological stations as a dataset named `bdmep_meta`.
-   \[x\] Functions (see below) were renamed to have consistent names. Now all functions have a 'bdmep' prefix. This allows you to type the prefix and see all the members of bdmep's family functions.
    -   `import_bdmep` changes to `bdmep_import`
    -   `data_description` changes to `bdmep_description`
-   \[x\] `bdmep_import()` changes:
    -   supports a vector of stations IDs allowing to data import from multiple meteorological stations.
    -   returned data frame include a new column `request status` (character) to inform on the outcome of the execution of the request on the server.

inmetr 0.0.3
============

-   \[x\] fixed issue (\#1, @sillasgonzaga).

-   \[x\] `import_bmep()` has a new argument `verbose` to print if the status of connection is ok.
