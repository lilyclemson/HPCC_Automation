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
    wuid := runResults[1].wuid;
    // msg := runResults[1].state;
    sendMsgToKafka :=  Util.sendMsg(wuid := wuid, msg := wuid + ' sending msg');
    logEndAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': success: ' + 'NA');

    RETURN SEQUENTIAL(logStartAction,sendMsgToKafka, logEndAction);


END;

thingsToDo := ORDERED

    (
        Util.genInstanceID;
        RunByNameAndWait('hpccsystems_covid19-test_spray_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_clean_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_country_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_states_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_metrics_by_us_county_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_FormateWeeklyMetrics_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_daily_metrics_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_catalog_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_grouped_kafka');
        RunByNameAndWait('hpccsystems_covid19-test_query_metrics_period_kafka');    
    );

thingsToDo : WHEN(CRON('0-59/5 * * * *'));
