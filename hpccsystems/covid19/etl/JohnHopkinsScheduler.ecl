IMPORT Std;
IMPORT $.^.Useful_ECL.WorkunitExec;

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

    RETURN SEQUENTIAL(logStartAction, logEndAction);
END;

thingsToDo := ORDERED

    (
        RunByNameAndWait('hpccsystems_covid19-test_spray_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_clean_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_country_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_states_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_county_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_global_metrics_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_FormateWeeklyMetrics_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_daily_metrics_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_catalog_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_grouped_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_period_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_countries_map_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_states_map_kafka');   
        RunByNameAndWait('hpccsystems_covid19-test_query_counties_map_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_daily_metrics_roxie_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_catalog_roxie_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_grouped_roxie_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_period_roxie_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_countries_map_roxie_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_states_map_roxie_kafka');   
        RunByNameAndWait('hpccsystems_covid19-test_query_counties_map_roxie_kafka');     
    );

thingsToDo : WHEN(CRON('0 0-23/6 * * *'));