IMPORT STD;

today := (STRING) (STD.Date.Today());
superFile := '~hpccsystems::covid19::superfile::public::johnhopkins::clean';
cleanFile := '~hpccsystems::covid19::file::public::johnhopkins::clean_' + today;

SEQUENTIAL(
    STD.File.StartSuperFileTransaction();
    STD.File.AddSuperFile(SuperFile, cleanFile);
    STD.File.FinishSuperFileTransaction();
);