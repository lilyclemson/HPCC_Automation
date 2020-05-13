IMPORT STD;
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkinsV1 as jhv1; 
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkinsV2 as jhv2; 
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkins as jh;

#WORKUNIT('name', 'Covid19-test');


Step0 := PARALLEL(IF(STD.File.SuperFileExists('~jhv2_temp'),STD.File.DeleteSuperFile('~jhv2_temp'));
IF(STD.File.SuperFileExists('~jhv1_temp'),STD.File.DeleteSuperFile('~jhv1_temp')));

lzip:= '10.0.0.6';
srcPath := '/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/JohnHopkins/V2/';
scopeName := '~hpccsystems::covid19-test::file::raw::JohnHopkins::V2::';
worldFlatPath := '~hpccsystems::covid19-test::file::public::johnhopkins::world.flat';
usFlatPath := '~hpccsystems::covid19-test::file::public::johnhopkins::us.flat';
worldFlatPath_temp := worldFlatPath + '_temp';
usFlatPath_temp := usFlatPath + '_temp';
today := STD.Date.Today();

// Read all the incoming files
incomingDS := STD.File.RemoteDirectory(lzip, SrcPath, '*.csv');
// OUTPUT(incomingDS);
l_incoming := RECORD
 STRING name;
 STRING logicalPath;
 UNSIGNED4 newdate;
 UNSIGNED4 modified;
END;
incomingFiles := PROJECT(incomingDS, 
                                TRANSFORM(l_incoming,
                                          SELF.logicalPath := scopeName + LEFT.name,
                                          SELF.newdate := Std.Date.FromStringToDate(
                                                                        LEFT.name[1..10],
                                                                        '%m-%d-%Y'),
                                          SELF.modified := Std.Date.FromStringToDate(
                                                                        LEFT.modified[1..10],
                                                                        '%Y-%m-%d'),
                                          SELF := LEFT));
newFiles := incomingFiles(modified = today );
OUTPUT(newFiles, NAMED('newFiles'));

//Spray the files
whereToSpray(STRING name) := FUNCTION
  updateFile := scopeName + name;
  run := STD.File.SprayDelimited
                        (
                            lzIP,
                            SrcPath+name,
                            destinationGroup := 'mythor',
                            destinationLogicalName :=updatefile,
                            allowOverwrite := TRUE,
                            recordStructurePresent := TRUE
                        );
  RETURN run;
END;
sprayfiles := NOTHOR(APPLY( newFiles,  whereToSpray(name)));
step1 := IF(EXISTS(newFiles), SprayFiles, OUTPUT('No Incoming Files'));


step2 := IF(EXISTS(newFiles),NOTHOR(SEQUENTIAL(
        STD.File.CreateSuperFile('~jhv2_temp'),
        STD.File.StartSuperFileTransaction(),
        APPLY(newFiles,STD.File.AddSuperFile('~jhv2_temp',logicalPath)),
        STD.File.FinishSuperFileTransaction())));

tempJhV2 :=  DATASET('~jhv2_temp', jhv2.layout, CSV(HEADING(1)));   

v2Clean := PROJECT(tempJhV2, 
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


base := DATASET(worldFlatPath, jh.layout, THOR);
newDates := SET(newFiles, newdate);
removeDatesFromBase := base(update_date NOT IN newDates);
OUTPUT(removeDatesFromBase);
updateBase := IF(EXISTS(newFiles),
                  IF(NOTHOR(STD.FILE.FILEEXISTS(worldFlatPath)),
                        removeDatesFromBase + v2Clean,
                        v2Clean));

// updateBase := IF(NOTHOR(STD.FILE.FILEEXISTS(worldFlatPath)),
//                         removeDatesFromBase + v2Clean,
//                         v2Clean);

step3 := SEQUENTIAL(
  OUTPUT(SORT(updateBase, -update_date), , worldFlatPath_Temp, OVERWRITE);
  OUTPUT(SORT(updateBase(country = 'US'), -update_date), , usFlatPath_Temp, OVERWRITE);
);
step4 := SEQUENTIAL(
  STD.File.RenameLogicalFile( worldFlatPath_Temp, worldFlatPath, TRUE );
  STD.File.RenameLogicalFile( usFlatPath_Temp, usFlatPath, TRUE );
);

step5 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));
trigger:= IF(EXISTS(newFiles),NOTIFY(EVENT('event2_1', 'success')));

ACTIONS := SEQUENTIAL(
           STEP0,
           STEP1,
           STEP2,
           STEP3,
           STEP4,
           STEP5
           ):SUCCESS(trigger);
// IF(EXISTS(newFiles), ACTIONS, OUTPUT('No incoming files yet')):WHEN(CRON('0 0-23/6 * * *'));
IF(EXISTS(newFiles), ACTIONS, OUTPUT('No incoming files yet')):WHEN(CRON('* * * * *'));


