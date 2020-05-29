IMPORT Std;
IMPORT $.^.Useful_ECL.WorkunitExec;
IMPORT TomboloKafka.Util;

RunByNameAndWait(STRING wuJobName) := FUNCTION
    runResults := WorkunitExec.RunCompiledWorkunitByName
        (
            wuJobName,
            waitForCompletion := TRUE,
            username := 'xulili01',
            userPW := 'Q4dRtHRF'
        );
    logStartAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': running ' + wuJobName);
    logEndAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': success: ' + IF(EXISTS(runResults), 'true', 'false'));
    wuid := runResults.wuid;
    guid :=  DATASET('~covid19::kafka::guid', {STRING s}, FLAT)[1].s;
    sendMsg := Util.sendMsg(wuid := wuid, instanceid := guid, msg := 'Message with instanceid ' + guid );
    RETURN SEQUENTIAL(logStartAction, sendMsg, logEndAction);
END;



thingsToDo := ORDERED

    (
        Util.genInstanceID;
        RunByNameAndWait('hpccsystems_covid19-test_spray');
        RunByNameAndWait('hpccsystems_covid19-test_clean');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_country');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_states');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_county');
        RunByNameAndWait('hpccsystems_covid19-test_global_metrics');
        RunByNameAndWait('hpccsystems_covid19-test_FormateWeeklyMetrics');
        RunByNameAndWait('hpccsystems_covid19-test_query_daily_metrics');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_catalog');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_grouped');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_period');
        RunByNameAndWait('hpccsystems_covid19-test_query_countries_map');
        RunByNameAndWait('hpccsystems_covid19-test_query_states_map');   
        RunByNameAndWait('hpccsystems_covid19-test_query_counties_map');
        RunByNameAndWait('hpccsystems_covid19-test_query_daily_metrics_roxie');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_catalog_roxie');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_grouped_roxie');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_period_roxie');
        RunByNameAndWait('hpccsystems_covid19-test_query_countries_map_roxie');
        RunByNameAndWait('hpccsystems_covid19-test_query_states_map_roxie');   
        RunByNameAndWait('hpccsystems_covid19-test_query_counties_map_roxie');     
    );

thingsToDo : WHEN(CRON('0-59/5 * * * *'));