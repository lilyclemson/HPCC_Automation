// #WORKUNIT('name', 'hpccsystems_covid19_query_metrics_catalog');

IMPORT hpccsystems.covid19.autoflow.files.WeeklyMetrics as metrics;
IMPORT STD;

_typeFilter := 'states':STORED('typeFilter');

defaultLocations := CASE (_typeFilter, 'states' => metrics.statesDefaultLocations, 'countries' => metrics.worldDefaultLocations, 'counties' => metrics.countiesDefaultLocations, metrics.statesDefaultLocations);
periodsCatalog := CASE (_typeFilter, 'states' => metrics.statesPeriodsCatalog, 'countries' => metrics.worldPeriodsCatalog, 'counties' => metrics.countiesPeriodsCatalog, metrics.statesPeriodsCatalog);

action1 := OUTPUT(CHOOSEN(defaultLocations,10),,NAMED('default_locations'));
action2 := OUTPUT(periodsCatalog,,NAMED('catalog_periods'));
action3 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));
trigger:=NOTIFY(EVENT('event4_3', 'success'));

ACTIONS := SEQUENTIAL(
           action1,
           action2,
           action3
           ):SUCCESS(trigger);
ACTIONS:WHEN(EVENT('event4_2', 'success'), COUNT(100));