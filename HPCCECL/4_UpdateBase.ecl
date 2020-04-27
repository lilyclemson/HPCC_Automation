IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh;

superFilePath:= '~hpccsystems::covid19::superfile::public::johnhopkins::clean';

superFile := DATASET(superFilePath, {jh.layout, UNSIGNED4 incomingDate}, FLAT);

disSF := DISTRIBUTE(superFile, HASH(country, state, fips));

sdSF := SORT(disSF,country, state, fips, update_date);
dsdSF:= DEDUP(sdSF, country, state, fips, update_date, BEST(-incomingDate));

OUTPUT(dsdSF, , '~hpccsystems::covid19::public::johnhopkins::world_flat', OVERWRITE);
OUTPUT(dsdSF(country = 'US'), , '~hpccsystems::covid19::public::johnhopkins::us_flat', OVERWRITE);

