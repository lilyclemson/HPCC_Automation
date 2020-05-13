// #WORKUNIT('name', 'metrics_by_us_county');

IMPORT Std;
IMPORT $.Types;
IMPORT $ AS COVID19;


statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

countyFilePath := '~hpccsystems::covid19-test::file::public::johnhopkins::us.flat';
_stateFilter := '':STORED('stateCountyFilter'); 

stateFilter := Std.Str.SplitWords(_stateFilter, ',');

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
countyDatIn0 := DATASET(countyFilePath, scRecord, THOR);
// Recompute the combined key to put state first
countyDatIn1 := PROJECT(countyDatIn0, TRANSFORM(RECORDOF(LEFT),
                                        SELF.combined_key := Std.Str.CleanSpaces(LEFT.state) + ',' + Std.Str.CleanSpaces(LEFT.admin2),
                                        SELF := LEFT));
countyDatIn2 := SORT(countyDatIn1, combined_key, update_date);
countyDatIn := countyDatIn2(update_date != 0 AND admin2 != '' AND admin2 != 'UNASSIGNED' AND (COUNT(stateFilter) = 0 OR state IN stateFilter));

ACTION1  := OUTPUT(countyDatIn[.. 10000], ALL, NAMED('us_county_metrics_Raw'));

statsData := PROJECT(countyDatIn, TRANSFORM(statsRec,
                                            SELF.location := LEFT.combined_key,
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.confirmed,
                                            SELF.cumDeaths := LEFT.deaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

ACTION2  := OUTPUT(statsData[.. 10000], ALL, NAMED('us_county_metrics_InputStats'));

popData := DATASET([], populationRec);

ACTION3  := OUTPUT(popData, NAMED('us_county_metrics_PopulationData'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
ACTION4  := OUTPUT(statsE, ,'~hpccsystems::covid19-test::file::public::metrics::daily_by_us_county.flat', Thor, OVERWRITE);

metrics := COVID19.CalcMetrics.WeeklyMetrics(statsData, popData);


ACTION5  := OUTPUT(metrics, ,'~hpccsystems::covid19-test::file::public::metrics::weekly_by_us_county.flat', Thor, OVERWRITE);

metricsRed := metrics[ .. 10000 ]; // Reduced set for wu output
ACTION6  := OUTPUT(metricsRed, ALL, NAMED('us_county_metrics_MetricsByWeek'));

sortedByCases := SORT(metricsRed, period, -cases);
ACTION7  := OUTPUT(sortedByCases, ALL, NAMED('us_county_metrics_metricsByCases'));
sortedByCR := SORT(metricsRed, period, -cR, location);
ACTION8  := OUTPUT(sortedByCR, ALL, NAMED('us_county_metrics_metricsByCR'));
sortedByMR := SORT(metricsRed, period, -mR, location);
ACTION9  := OUTPUT(sortedByMR, ALL, NAMED('us_county_metrics_metricsByMR'));
sortedByCMRatio := SORT(metricsRed, period, -cmRatio, location);
ACTION10  := OUTPUT(sortedByCMRatio, ALL, NAMED('us_county_metrics_metricsByCMRatio'));

sortedByPerCapita := SORT(metricsRed, period, -cases_per_capita, location);
ACTION11  := OUTPUT(sortedByPerCapita, ALL, NAMED('us_county_metrics_metricsByPerCapitaCases'));

sortedByDCR := SORT(metricsRed, period, dcR, location);
ACTION12  := OUTPUT(sortedByDCR, ALL, NAMED('us_county_metrics_metricsByDCR'));

sortedByDMR := SORT(metricsRed, period, dmR, location);
ACTION13  := OUTPUT(sortedByDMR, ALL, NAMED('us_county_metrics_metricsByDMR'));

sortedByMedInd := SORT(metrics(medIndicator != 0), period, medIndicator, location);
ACTION14  := OUTPUT(sortedByMedInd, ALL, NAMED('us_county_metrics_metricsByMedicalIndicator'));

sortedBySdInd := SORT(metrics(sdIndicator != 0), period, sdIndicator, location);
ACTION15  := OUTPUT(sortedBySdInd, ALL, NAMED('us_county_metrics_metricsBySocialDistanceIndicator'));

withSeverity := JOIN(metrics(period = 1 AND iState != 'Initial'), COVID19.iStateSeverity, LEFT.iState = RIGHT.stateName, TRANSFORM({metricsRec, UNSIGNED severity},
                          SELF.severity := RIGHT.severity, SELF := LEFT), LOOKUP);
sortedBySeverity := SORT(withSeverity, -severity, location);
ACTION16  := OUTPUT(sortedBySeverity, ALL, NAMED('us_county_metrics_ByInfectionState'));

sortedByHeatIndx := COVID19.HotSpotsRpt(metrics);
ACTION17  := OUTPUT(sortedByHeatIndx, ALL, NAMED('us_county_metrics_HotSpots'));
ACTION18 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));

trigger:=NOTIFY(EVENT('event3', 'success'));
ACTIONS := SEQUENTIAL(
                              // action1,
                              // action2,
                              // action3,
                              action4,
                              action5,
                              // action6,
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
                              // action17,
                              ACTION18
                              ):SUCCESS(trigger);
ACTIONS:WHEN(EVENT('event2_3', 'success'), COUNT(100));
