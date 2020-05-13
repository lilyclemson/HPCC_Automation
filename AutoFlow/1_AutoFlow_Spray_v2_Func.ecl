IMPORT STD;
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkinsV1 as jhv1; 
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkinsV2 as jhv2; 
IMPORT hpccsystems.covid19.autoflow.files.JohnHopkins as jh;
IMPORT hpccsystems.covid19.autoflow.files as files;
IMPORT hpccsystems.covid19.autoflow.Utils as Utils;

#WORKUNIT('name', 'Covid19-test');

today := STD.Date.Today();

//Delete Previously created SuperFiles
Step0 := PARALLEL(IF(STD.File.SuperFileExists(Files.SuperFilePathV2),STD.File.DeleteSuperFile(Files.SuperFilePathV2));
IF(STD.File.SuperFileExists(Files.SuperFilePathV1),STD.File.DeleteSuperFile(Files.SuperFilePathV1)));


// Read today's new files on LZ 
incomingDS := STD.File.RemoteDirectory(files.lzip, files.SrcPath, '*.csv');
incomingFiles := PROJECT(incomingDS, 
                                TRANSFORM(files.l_incoming,
                                          SELF.logicalPath := files.scopeName + LEFT.name,
                                          SELF.newdate := Std.Date.FromStringToDate(
                                                                        LEFT.name[1..10],
                                                                        '%m-%d-%Y'),
                                          SELF.modified := Std.Date.FromStringToDate(
                                                                        LEFT.modified[1..10],
                                                                        '%Y-%m-%d'),
                                          SELF := LEFT));
newFiles := incomingFiles(modified = today );
OUTPUT(newFiles, NAMED('newFiles'));
newDates := SET(newFiles, newdate);

//Spray the files
sprayfiles := NOTHOR(APPLY(newFiles,  Utils.whereToSpray(name, logicalPath)));
step1 := SprayFiles;

//Create Temp SuperFile
step2 := NOTHOR(SEQUENTIAL(
                STD.File.CreateSuperFile(Files.SuperFilePathv2),
                STD.File.StartSuperFileTransaction(),
                APPLY(newFiles,STD.File.AddSuperFile(Files.SuperFilePathv2,logicalPath)),
                STD.File.FinishSuperFileTransaction()
                ));

// Clean SuperFile and Update BaseFiles
UpdateBase  := Utils.UpdateBaseFiles(files.worldFlatPath, newDates);
step3 := SEQUENTIAL(
  OUTPUT(SORT(updateBase, -update_date), , files.worldFlatPath_Temp, OVERWRITE);
  OUTPUT(SORT(updateBase(country = 'US'), -update_date), , files.usFlatPath_Temp, OVERWRITE);
  STD.File.RenameLogicalFile( files.worldFlatPath_Temp, files.worldFlatPath, TRUE );
  STD.File.RenameLogicalFile( files.usFlatPath_Temp, files.usFlatPath, TRUE );
);


// NOTIFY next event when it's completed
trigger:= NOTIFY(EVENT('event2_1', 'success'));
step4 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True)):SUCCESS(trigger);
// step4 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));


// Excute step by step 
ACTIONS := IF(EXISTS(newFiles),
            SEQUENTIAL(
                        STEP0,
                        STEP1,
                        STEP2,
                        STEP3,
                        STEP4),
            OUTPUT('No incoming files yet'));

// Setup Scheduler
ACTIONS:WHEN(CRON('0-59/30 * * * *'));


// ACTIONS;