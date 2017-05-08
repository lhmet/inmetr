# inmetr 0.0.2.9000
- [x] remove dependence on plyr
- [x] rename functions
    - from `import_bdmep` to `bdmep_import` 
    - from `data_description` to `bdmep_description`
- [x] `bdmep_import()` supports a vector of stations IDs allowing to data import from multiple meteorological stations.
- [x] change the name of the first argument of `bdmep_import()` from `id` to `ids` to emphasize the new feature.
- [ ] get stations metadata from [here]("http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls")
- [ ] add function to provide daily data.
- [ ] add function to write csv files of station data.
- [ ] fix note about zenodo


# inmetr 0.0.2

- fixed issue (#1, @sillasgonzaga)

- `import_bmep()` has a new argument `verbose` to print if the status of connection is ok.  