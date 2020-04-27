IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV2 as jhv2;
IMPORT Std;

today := (STRING) (STD.Date.Today());
todayRawFileName := '~hpccsystems::covid19::raw::johnhopkins::incoming_'+ today + '.csv';
todayRawFile := DATASET(todayRawFileName, jhv2.layout, CSV(HEADING(1)));

CleanJHRaw(DATASET(jhv2.layout) ds) := FUNCTION
  v2CleanDs := PROJECT(ds , 
                          TRANSFORM
                              (
                                  {jh.layout, UNSIGNED4 incomingDate},
                                  SELF.fips  := LEFT.fips,
                                  SELF.admin2 := Std.Str.ToUpperCase(LEFT.admin2), 
                                  SELF.state := Std.Str.ToUpperCase(LEFT.state),
                                  SELF.country := IF(LEFT.country='Korea, South','SOUTH KOREA',Std.Str.ToUpperCase(LEFT.country)),
                                  SELF.geo_lat := (DECIMAL9_6)LEFT.geo_lat,
                                  SELF.geo_long := (DECIMAL9_6)LEFT.geo_long,
                                  dt := Std.Date.ConvertDateFormatMultiple(LEFT.last_update, ['%Y-%m-%d', '%m/%d/%y'], '%Y-%m-%d');
                                  SELF.update_date :=  Std.Date.FromStringToDate(dt, '%Y-%m-%d');
                                  SELF.confirmed := (UNSIGNED4)LEFT.confirmed,
                                  SELF.deaths := (UNSIGNED4)LEFT.deaths,
                                  SELF.recovered := (UNSIGNED4)LEFT.recovered,
                                  SELF.active := (UNSIGNED4)LEFT.active,
                                  SELF.combined_key := Std.Str.ToUpperCase(LEFT.combined_key),
                                  SELF.incomingDate := (INTEGER)today;
                              )
                );  

  clean := SORT(v2CleanDs, -update_date);

  RETURN clean;
END;


JHUpdate := CleanJHRaw(todayRawFile);

CleanFilePrefix := '~hpccsystems::covid19::file::public::johnhopkins::clean_' + today;

OUTPUT(JHUpdate, , CleanFilePrefix, OVERWRITE);