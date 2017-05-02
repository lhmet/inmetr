# inmetr 0.0.2.9000

- [x] remove dependence on plyr
- [x] `import_bdmep()` supports a vector of stations IDs allowing to data import from multiple meteorological stations.
- [x] change the name of the first argument of `import_bdmep()` from `id` to `ids` to emphasize the new feature.
- [ ] add function to write csv files of station data.
- [ ] add function to provide daily data.

# inmetr 0.0.2

- fixed issue (@sillasgonzaga, #1)

- `import_bmep()` has a new argument `verbose` to print if the status of connection is ok.  