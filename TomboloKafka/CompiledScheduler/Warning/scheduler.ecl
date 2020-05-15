IMPORT CompiledScheduler.Useful_ECL.WorkunitExec;
IMPORT STD;

RunByNameAndWait(STRING wuJobName) := FUNCTION
    runResults := WorkunitExec.RunCompiledWorkunitByName
        (
            wuJobName,
            waitForCompletion := TRUE
        );
    logStartAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': running ' + wuJobName);
    logEndAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': success: ' + IF(EXISTS(runResults), 'true', 'false'));

    RETURN SEQUENTIAL(logStartAction, logEndAction);
END;

genInstanceID := FUNCTION
    guid := STD.Date.Today() + '' + STD.Date.CurrentTime(True);
    guidDS := DATASET(ROW({guid}, {STRING s}));
    RETURN OUTPUT( guidDS, , '~covid19::kafka::guid', OVERWRITE);
END;

thingsToDo := ORDERED

    (   
        genInstanceID;
        RunByNameAndWait('0_start');
        RunByNameAndWait('1_clean');
        RunByNameAndWait('2_end');
   
    );

thingsToDo : WHEN(CRON('0-59/2 * * * *'));