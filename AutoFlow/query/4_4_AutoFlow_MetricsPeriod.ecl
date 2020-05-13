// #WORKUNIT('name', 'hpccsystems_covid19_query_metrics_period');

IMPORT hpccsystems.covid19.autoflow.files.WeeklyMetrics as metrics;
IMPORT STD;

_typeFilter := 'states':STORED('typeFilter');
_periodFilter := 1:STORED('periodFilter');

allData := CASE (_typeFilter, 'states' => metrics.statesAll, 'countries' => metrics.worldAll, 'counties' => metrics.countiesAll, metrics.statesAll);

filtered := SORT(allData(period = _periodFilter),-heatindex);

action1 := OUTPUT(CHOOSEN(filtered, 10000),,NAMED('metrics_period'));
action2 := OUTPUT(CHOOSEN(TABLE(filtered, {location}), 10),,NAMED('default_locations'));
action3 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));

trigger:=OUTPUT('AutoFlow Finished');

ACTIONS := SEQUENTIAL(
           action1,
           action2,
           action3
           ):SUCCESS(trigger);
ACTIONS:WHEN(EVENT('event4_4', 'success'), COUNT(100));