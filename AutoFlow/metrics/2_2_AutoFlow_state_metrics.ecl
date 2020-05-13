// #WORKUNIT('name', 'metrics_by_us_states');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types;
IMPORT $ AS COVID19;


statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

rawFilePath := '~hpccsystems::covid19-test::file::public::johnhopkins::us.flat';

scRecord := RECORD
  string50 fips;
  string admin2;
  string state;
  string country;
  unsigned4 update_date;
  decimal9_6 geo_lat;
  decimal9_6 geo_long;
  unsigned4 confirmed;
  unsigned4 deaths;
  unsigned4 recovered;
  unsigned4 active;
  string combined_key;
 END;

// Filter county info
rawDatIn0 := SORT(DATASET(rawFilePath, scRecord, THOR), state);
ACTION1  := OUTPUT(rawDatIn0[..10000], ALL, NAMED('state_metrics_Raw'));
//ACTION  := OUTPUT(rawDatIn0(update_date = 0), ALL, NAMED('state_metrics_RawBadDate'));

// Roll up the data by state
rawDatIn1 := TABLE(rawDatIn0, {state, update_date, stConfirmed := SUM(GROUP, confirmed), stDeaths := SUM(GROUP, deaths)}, state, update_date);


_statesFilter := '':STORED('statesFilter');

statesFilter := Std.Str.SplitWords(_statesFilter, ',');

// Filter out bad state info
rawDatIn := SORT(rawDatIn1(state != '' AND update_date > 0 AND (COUNT(statesFilter) = 0 OR state IN statesFilter)), state, update_date);

statsData := PROJECT(rawDatIn, TRANSFORM(statsRec,
                                            SELF.location := LEFT.state,
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.stConfirmed,
                                            SELF.cumDeaths := LEFT.stDeaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

ACTION2  := OUTPUT(statsData[ .. 10000], ALL, NAMED('state_metrics_InputStats'));
popDatIn := pop.clean;
popData := PROJECT(popDatIn, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state,
                                    SELF.population := LEFT.pop_2018));

ACTION3  := OUTPUT(popData, NAMED('state_metrics_PopulationData'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
ACTION4  := OUTPUT(statsE, ,'~hpccsystems::covid19-test::file::public::metrics::daily_by_state.flat', Thor, OVERWRITE);

metrics := COVID19.CalcMetrics.WeeklyMetrics(statsData, popData);

ACTION5  := OUTPUT(metrics, ALL, NAMED('state_metrics_MetricsByWeek'));
ACTION6  := OUTPUT(metrics, ,'~hpccsystems::covid19-test::file::public::metrics::weekly_by_state.flat', Thor, OVERWRITE);
sortedByCR := SORT(metrics, period, -cR, location);
ACTION7  := OUTPUT(sortedByCR, ALL, NAMED('state_metrics_metricsByCR'));
sortedByMR := SORT(metrics, period, -mR, location);
ACTION8  := OUTPUT(sortedByMR, ALL, NAMED('state_metrics_metricsByMR'));
sortedByCMRatio := SORT(metrics, period, -cmRatio, location);
ACTION9  := OUTPUT(sortedByCMRatio, ALL, NAMED('state_metrics_metricsByCMRatio'));

sortedByPerCapita := SORT(metrics, period, -cases_per_capita, location);
ACTION10  := OUTPUT(sortedByPerCapita, ALL, NAMED('state_metrics_metricsByPerCapitaCases'));

sortedByDCR := SORT(metrics, period, dcR, location);
ACTION11  := OUTPUT(sortedByDCR, ALL, NAMED('state_metrics_metricsByDCR'));

sortedByDMR := SORT(metrics, period, dmR, location);
ACTION12  := OUTPUT(sortedByDMR, ALL, NAMED('state_metrics_metricsByDMR'));

sortedByMedInd := SORT(metrics(medIndicator != 0), period, medIndicator, location);
ACTION13  := OUTPUT(sortedByMedInd, ALL, NAMED('state_metrics_metricsByMedicalIndicator'));

sortedBySdInd := SORT(metrics(sdIndicator != 0), period, sdIndicator, location);
ACTION14  := OUTPUT(sortedBySdInd, ALL, NAMED('state_metrics_metricsBySocialDistanceIndicator'));

sortedByWeeksToPeak := SORT(metrics(period = 1 AND weeksToPeak > 0 AND weeksToPeak < 999), weeksToPeak, location);
ACTION15  := OUTPUT(sortedByWeeksToPeak, NAMED('state_metrics_metricsByWeeksToPeak'));

withSeverity := JOIN(metrics(period = 1), COVID19.iStateSeverity, LEFT.iState = RIGHT.stateName, TRANSFORM({metricsRec, UNSIGNED severity},
                          SELF.severity := RIGHT.severity, SELF := LEFT), LOOKUP);
sortedBySeverity := SORT(withSeverity, -severity, location);
ACTION16  := OUTPUT(sortedBySeverity, ALL, NAMED('state_metrics_ByInfectionState'));

sortedByHeatIndx := COVID19.HotSpotsRpt(metrics);
ACTION17  := OUTPUT(sortedByHeatIndx, ALL, NAMED('state_metrics_HotSpots'));
ACTION18 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));
trigger:=NOTIFY(EVENT('event2_3', 'success'));

ACTIONS := SEQUENTIAL(
                                // action1,
//                               action2,
//                               action3,
                              action4,
                              // action5,
                              action6,
                              // action7,
                              // action8,
                              // action9,
                              // action10,
                              // action11;
                              // action12,
                              // action13,
                              // action14,
                              // action15,
                              // action16,
                              // action17
                              ACTION18
                              ):SUCCESS(trigger);
ACTIONS:WHEN(EVENT('event2_2', 'success'), COUNT(100));
