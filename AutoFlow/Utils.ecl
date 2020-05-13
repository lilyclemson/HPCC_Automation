IMPORT STD;
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkinsV2 as jhv2; 
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkins as jh;
IMPORT hpccsystems.covid19.autoflow.files as files;

EXPORT Utils := MODULE
EXPORT whereToSpray(STRING name, STRING logicalPath) := FUNCTION
  run := STD.File.SprayDelimited
                        (
                            files.lzIP,
                            files.SrcPath+ name,
                            destinationGroup := 'mythor',
                            destinationLogicalName :=logicalPath,
                            allowOverwrite := TRUE,
                            recordStructurePresent := TRUE
                        );
  RETURN run;
END;


EXPORT clean(STRING SFPath) := FUNCTION
ds := DATASET(SFPath, jhv2.layout, CSV(HEADING(1)));
v2Clean := PROJECT(ds, 
                    TRANSFORM
                        (
                            jh.layout,
                            SELF.fips  := LEFT.fips,
                            SELF.admin2 := Std.Str.ToUpperCase(LEFT.admin2), 
                            SELF.state := Std.Str.ToUpperCase(LEFT.state),
                            SELF.country := IF(LEFT.country='Korea, South','SOUTH KOREA',Std.Str.ToUpperCase(LEFT.country)),
                            SELF.geo_lat := (DECIMAL9_6)LEFT.geo_lat,
                            SELF.geo_long := (DECIMAL9_6)LEFT.geo_long,
                            dtStr := LEFT.fileName[LENGTH(LEFT.fileName)-13..LENGTH(LEFT.fileName)-4];
                            SELF.update_date :=  Std.Date.FromStringToDate(dtStr, '%m-%d-%Y');
                            SELF.confirmed := (UNSIGNED4)LEFT.confirmed,
                            SELF.deaths := (UNSIGNED4)LEFT.deaths,
                            SELF.recovered := (UNSIGNED4)LEFT.recovered,
                            SELF.active := (UNSIGNED4)LEFT.active,
                            SELF.combined_key := Std.Str.ToUpperCase(LEFT.combined_key)
                        )
            );  
RETURN v2clean;
END;

EXPORT UpdateBaseFiles(STRING basePath, SET OF UNSIGNED4 incomingDates ) := FUNCTION
v2Clean  := Clean(Files.SuperFilePathv2);
base := DATASET(basePath, jh.layout, THOR);
removeDatesFromBase := base(update_date NOT IN incomingDates);
updateBase := IF(NOTHOR(STD.FILE.FILEEXISTS(files.worldFlatPath)),
                        removeDatesFromBase + v2Clean,
                        v2Clean);
RETURN updateBase;
END;

END;