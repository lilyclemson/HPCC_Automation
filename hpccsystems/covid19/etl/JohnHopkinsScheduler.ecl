IMPORT Std;
IMPORT $.^.Useful_ECL.WorkunitExec;

RunByNameAndWait(STRING wuJobName) := FUNCTION
    runResults := WorkunitExec.RunCompiledWorkunitByName
        (
            wuJobName,
            waitForCompletion := TRUE,
            username := '',
            userPW := ''
        );
    logStartAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': running ' + wuJobName);
    logEndAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': success: ' + IF(EXISTS(runResults), 'true', 'false'));

    RETURN SEQUENTIAL(logStartAction, logEndAction);
END;

thingsToDo := ORDERED

    (
        RunByNameAndWait('hpccsystems_covid19-test_spray');
        RunByNameAndWait('hpccsystems_covid19-test_clean');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_country');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_states');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_county');
        RunByNameAndWait('hpccsystems_covid19-test_FormateWeeklyMetrics');
        RunByNameAndWait('hpccsystems_covid19-test_query_daily_metrics');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_catalog');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_grouped');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_period');    
    );

thingsToDo : WHEN(CRON('0 0-23/6 * * *'));
