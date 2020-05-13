// #WORKUNIT('name', 'hpccsystems_covid19_query_metrics_grouped');

IMPORT hpccsystems.covid19.autoflow.files.WeeklyMetrics as metrics;
IMPORT Std;

_typeFilter := 'states':STORED('typeFilter');
_periodFilter := 1:STORED('periodFilter');
locationsFilter := '':STORED('locationsFilter'); 
_locationsFilter := Std.Str.SplitWords(locationsFilter, ',');

allData := CASE (_typeFilter, 'states' => metrics.statesGrouped, 'countries' => metrics.worldGrouped, 'counties' => metrics.countiesGrouped, metrics.statesGrouped);

filtered := allData(period = _periodFilter and location in _locationsFilter);
action1 := OUTPUT(CHOOSEN(filtered, 10000),,NAMED('metrics_grouped'));
action2 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));
trigger:=NOTIFY(EVENT('event4_4', 'success'));

ACTIONS := SEQUENTIAL(
           action1,
           action2
           ):SUCCESS(trigger);
ACTIONS:WHEN(EVENT('event4_3', 'success'), COUNT(100));

