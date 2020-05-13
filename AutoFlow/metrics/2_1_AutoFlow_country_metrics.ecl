// #WORKUNIT('name', 'metrics_by_country');

IMPORT Std;
IMPORT $.Types;

IMPORT $ AS COVID19;
IMPORT $.Types;

metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

rawFilePath := '~hpccsystems::covid19-test::file::public::johnhopkins::world.flat';

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

_countryFilter := '':STORED('countryFilter'); 
countryFilter := Std.Str.SplitWords(_countryFilter, ',');

// Filter county info
rawData0 := DATASET(rawFilePath, scRecord, THOR);
rawData1 := SORT(rawData0, country, state, admin2, update_date);
rawData2 := DEDUP(rawData1, country, state, admin2, update_date);

// Filter out bad country info
rawData3 := rawData2(country != '' AND update_date != 0 AND (COUNT(countryFilter) = 0 OR country IN countryFilter));
//ACTION  := OUTPUT(rawData3[..10000], ALL, NAMED('country_metrics_rawData'));
//ACTION  := OUTPUT(rawData3(country = 'CHINA'), ALL, NAMED('country_metrics_ChinaRaw'));
// Make sure there are no missing dates for any of the regions.
//rawData4 := COVID19.FixupMissingDates(rawData3);
rawData4 := rawData3;
//ACTION  := OUTPUT(rawData4[..10000], ALL, NAMED('country_metrics_fixedupData'));
//ACTION  := OUTPUT(rawData4(country = 'CHINA'), ALL, NAMED('country_metrics_ChinaFixed'));
// Roll up the data by country for each date
rollupDat := SORT(TABLE(rawData4, {country, update_date, cConfirmed := SUM(GROUP, confirmed), cDeaths := SUM(GROUP, deaths)}, country, update_date), country, update_date);
// Temp for China fixup
chinaDat := rollupDat(country = 'CHINA');
//ACTION  := OUTPUT(chinaDat, ALL,  NAMED('country_metrics_ChinaDataFixed'));

statsData := PROJECT(rollupDat, TRANSFORM(statsRec,
                                            SELF.date := LEFT.update_date,
                                            SELF.location := LEFT.country,
                                            SELF.cumCases := LEFT.cConfirmed,
                                            SELF.cumDeaths := LEFT.cDeaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

ACTION1  := OUTPUT(statsData, ALL, NAMED('country_metrics_InputStats'));

popData := DATASET([], populationRec);

ACTION2  := OUTPUT(popData, NAMED('country_metrics_PopulationData'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
ACTION3  := OUTPUT(statsE, ,'~hpccsystems::covid19-test::file::public::metrics::daily_by_country.flat', Thor, OVERWRITE);

metrics0 := CalcMetrics.WeeklyMetrics(statsData, popData);

// Filter out some bad country names that only had data for one period
metrics := metrics0(period != 1 OR endDate > 20200401);


ACTION4  := OUTPUT(metrics, ALL, NAMED('country_metrics_MetricsByWeek'));
ACTION5  := OUTPUT(metrics, ,'~hpccsystems::covid19-test::file::public::metrics::weekly_by_country.flat', Thor, OVERWRITE);
sortedByCR := SORT(metrics, period, -cR, location);
ACTION6  := OUTPUT(sortedByCR, ALL, NAMED('country_metrics_metricsByCR'));
sortedByMR := SORT(metrics, period, -mR, location);
ACTION7  := OUTPUT(sortedByMR, ALL, NAMED('country_metrics_metricsByMR'));
sortedByCMRatio := SORT(metrics, period, -cmRatio, location);
ACTION8  := OUTPUT(sortedByCMRatio, ALL, NAMED('country_metrics_metricsByCMRatio'));

sortedByPerCapita := SORT(metrics, period, -cases_per_capita, location);
ACTION9  := OUTPUT(sortedByPerCapita, ALL, NAMED('country_metrics_metricsByPerCapitaCases'));

sortedByDCR := SORT(metrics, period, dcR, location);
ACTION10  := OUTPUT(sortedByDCR, ALL, NAMED('country_metrics_metricsByDCR'));

sortedByDMR := SORT(metrics, period, dmR, location);
ACTION11  := OUTPUT(sortedByDMR, ALL, NAMED('country_metrics_metricsByDMR'));

sortedByMedInd := SORT(metrics(medIndicator != 0), period, medIndicator, location);
ACTION12  := OUTPUT(sortedByMedInd, ALL, NAMED('country_metrics_metricsByMedicalIndicator'));

sortedBySdInd := SORT(metrics(sdIndicator != 0), period, sdIndicator, location);
ACTION13  := OUTPUT(sortedBySdInd, ALL, NAMED('country_metrics_metricsBySocialDistanceIndicator'));

sortedByWeeksToPeak := SORT(metrics(period = 1 AND weeksToPeak > 0 AND weeksToPeak < 999), weeksToPeak, location);
ACTION14  := OUTPUT(sortedByWeeksToPeak, NAMED('country_metrics_metricsByWeeksToPeak'));

withSeverity := JOIN(metrics(period = 1), COVID19.iStateSeverity, LEFT.iState = RIGHT.stateName, TRANSFORM({metricsRec, UNSIGNED severity},
                          SELF.severity := RIGHT.severity, SELF := LEFT), LOOKUP);
sortedBySeverity := SORT(withSeverity, -severity, location);
ACTION15  := OUTPUT(sortedBySeverity, ALL, NAMED('country_metrics_ByInfectionState'));

sortedByHeatIndx := COVID19.HotSpotsRpt(metrics);
ACTION16  := OUTPUT(sortedByHeatIndx, ALL, NAMED('country_metrics_HotSpots'));

worldTotals0 := TABLE(metrics, {INTEGER weekEnding := endDate, totCases := SUM(GROUP, cases), totDeaths := SUM(GROUP, deaths), totActive := SUM(GROUP, active), totRecovered := SUM(GROUP, recovered), metric_t Avg_cR := AVE(GROUP, cR, cR > 0), metric_t Avg_mR := AVE(GROUP, mR, mR > 0), metric_t avg_iMort := AVE(GROUP, iMort, iMort > 0)}, endDate);
worldTotals := SORT(worldTotals0, -weekEnding);
ACTION17  := OUTPUT(worldTotals, NAMED('country_metrics_WorldTotals'));

ACTION18 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True));

trigger:=NOTIFY(EVENT('event2_2', 'success'));

ACTIONS := SEQUENTIAL(
                              // action1,
                              // action2,
                              action3,
                              // action4,
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
                              // action17
                              action18
                              ):SUCCESS(trigger);
ACTIONS:WHEN(EVENT('event2_1', 'success'), COUNT(100));
