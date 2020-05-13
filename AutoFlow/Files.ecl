IMPORT STD;

EXPORT Files := MODULE
    EXPORT SuperFilePathv1 := '~jhv1_temp';
    EXPORT SuperFilePathv2 := '~jhv2_temp';
    EXPORT lzip:= '10.0.0.6';
    EXPORT srcPath := '/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/JohnHopkins/V2/';
    EXPORT scopeName := '~hpccsystems::covid19-test::file::raw::JohnHopkins::V2::';
    EXPORT worldFlatPath := '~hpccsystems::covid19-test::file::public::johnhopkins::world.flat';
    EXPORT usFlatPath := '~hpccsystems::covid19-test::file::public::johnhopkins::us.flat';
    EXPORT worldFlatPath_temp := worldFlatPath + '_temp';
    EXPORT usFlatPath_temp := usFlatPath + '_temp';

    EXPORT l_incoming := RECORD
    STRING name;
    STRING logicalPath;
    UNSIGNED4 newdate;
    UNSIGNED4 modified;
    END;

    EXPORT JohnHopkinsV1 := MODULE

    EXPORT filePath := '~{hpccsystems::covid19-test::file::raw::JohnHopkins::V1::03-21-2020.csv,' +
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V1::03-20-2020.csv,' +
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V1::03-19-2020.csv,' +
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V1::03-18-2020.csv,' + 
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V1::03-17-2020.csv}';  

    EXPORT layout := RECORD
        STRING state;
        STRING country;
        STRING last_update;
        STRING confirmed;
        STRING deaths;
        STRING recovered;
        STRING geo_lat;
        STRING geo_long;
    END;

    EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

    END;



    EXPORT JohnHopkinsV2 := MODULE 
        EXPORT filePath := '~{hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-22-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-23-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-24-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-25-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-26-2020.csv,'+ 
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-27-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-28-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-29-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-30-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::03-31-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-01-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-02-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-03-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-04-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-05-2020.csv,'+ 
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-06-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-07-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-08-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-09-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-10-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-11-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-12-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-13-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-14-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-15-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-16-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-17-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-18-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-19-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-20-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-21-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-22-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-23-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-24-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-25-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-26-2020.csv,' +  
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-27-2020.csv,'+
                            'hpccsystems::covid19-test::file::raw::JohnHopkins::V2::04-28-2020.csv' + '}'; 

        EXPORT layout := RECORD
            STRING fips;
            STRING admin2; 
            STRING state;
            STRING country;
            STRING last_update;
            STRING geo_lat;
            STRING geo_long;
            STRING confirmed;
            STRING deaths;
            STRING recovered;
            STRING active;
            STRING combined_key;
            STRING fileName {VIRTUAL(logicalfilename)}

        END;

        EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  
    END;

    EXPORT JohnHopkins := MODULE 
        
        EXPORT worldFilePath := '~hpccsystems::covid19-test::file::public::johnhopkins::world.flat';  
        EXPORT usFilePath := '~hpccsystems::covid19-test::file::public::johnhopkins::US.flat';

        EXPORT layout := RECORD
            STRING50 fips;
            STRING50 admin2;
            STRING50 state;
            STRING50 country;
            Std.Date.Date_t update_date;
            DECIMAL9_6 geo_lat;
            DECIMAL9_6 geo_long;
            UNSIGNED4 confirmed;
            UNSIGNED4 deaths;
            UNSIGNED4 recovered;
            UNSIGNED4 active;
            STRING50 combined_key;
        END;

        EXPORT worldDs := DATASET(worldFilePath, layout, THOR);//ds will always be the default
        EXPORT usDs := DATASET(usFilePath, layout, THOR);
    END;


    EXPORT WeeklyMetrics := MODULE
    
    EXPORT statesPath := '~hpccsystems::covid19-test::file::public::metrics::weekly_by_state.flat';
    EXPORT worldPath := '~hpccsystems::covid19-test::file::public::metrics::weekly_by_country.flat';
    EXPORT countiesPath := '~hpccsystems::covid19-test::file::public::metrics::weekly_by_us_county.flat';  

    export inputLayout := RECORD 
    string location;
    unsigned8 period;
    unsigned4 startdate;
    unsigned4 enddate;
    string istate;
    unsigned8 cases;
    unsigned8 deaths;
    unsigned8 active;
    decimal5_2 cr;
    decimal5_2 mr;
    decimal5_2 sdindicator;
    decimal5_2 medindicator;
    decimal6_3 heatindex;
    decimal5_3 imort;
    decimal5_2 immunepct;
    DECIMAL8_2 newcases;
    DECIMAL8_2 newdeaths;
    unsigned8 recovered;
    decimal5_2 cases_per_capita;
    decimal5_2 deaths_per_capita;
    decimal5_2 cmratio;
    decimal5_2 dcr;
    decimal5_2 dmr;
    decimal5_2 weekstopeak;
    unsigned8 perioddays;
    unsigned8 population;
    END;

    export layout := RECORD
        inputLayout;
        string parentLocation := '';//counties
    END;

    EXPORT GroupedLayout := RECORD
        string location;
        string locationstatus;
        unsigned8 period;
        unsigned4 startdate;
        unsigned4 enddate;
        unsigned8 perioddays;
        STRING50  measure := ''; 
        DECIMAL8_2     value := 0; 
    END;

    EXPORT LocationLayout := RECORD
        string location;
    END;

    EXPORT CatalogLayout := RECORD
        STRING50 id;
        STRING50 title;
    end;  

    EXPORT states := DATASET(statesPath, inputLayout, THOR);
    EXPORT world := DATASET(worldPath, inputLayout, THOR); 
    EXPORT counties := DATASET(countiesPath, inputLayout, THOR);


    EXPORT statesGroupedPath := '~hpccsystems::covid19-test::file::public::metrics::states_grouped.flat';
    EXPORT statesAllPath := '~hpccsystems::covid19-test::file::public::metrics::states_all.flat';
    EXPORT statesLocationsCatalogPath := '~hpccsystems::covid19-test::file::public::metrics::states_locations_catalog.flat';
    EXPORT statesDefaultLocationsPath := '~hpccsystems::covid19-test::file::public::metrics::states_locations_default.flat';
    EXPORT statesPeriodsCatalogPath := '~hpccsystems::covid19-test::file::public::metrics::states_periods_catalog.flat';

    EXPORT statesGrouped := DATASET(statesGroupedPath, GroupedLayout, THOR);
    EXPORT statesAll := DATASET(statesAllPath, Layout, THOR);
    EXPORT statesLocationsCatalog := DATASET(statesLocationsCatalogPath,CatalogLayout , THOR);
    EXPORT statesDefaultLocations := DATASET(statesDefaultLocationsPath,LocationLayout, THOR);
    EXPORT statesPeriodsCatalog := DATASET(statesPeriodsCatalogPath,CatalogLayout, THOR);


    EXPORT worldGroupedPath := '~hpccsystems::covid19-test::file::public::metrics::world_grouped.flat';
    EXPORT worldAllPath := '~hpccsystems::covid19-test::file::public::metrics::world_all.flat';
    EXPORT worldLocationsCatalogPath := '~hpccsystems::covid19-test::file::public::metrics::world_locations_catalog.flat';
    EXPORT worldDefaultLocationsPath := '~hpccsystems::covid19-test::file::public::metrics::world_locations_default.flat';
    EXPORT worldPeriodsCatalogPath := '~hpccsystems::covid19-test::file::public::metrics::world_periods_catalog.flat';

    EXPORT worldGrouped := DATASET(worldGroupedPath, GroupedLayout, THOR);
    EXPORT worldAll := DATASET(worldAllPath, Layout, THOR);
    EXPORT worldLocationsCatalog := DATASET(worldLocationsCatalogPath,CatalogLayout , THOR);
    EXPORT worldDefaultLocations := DATASET(worldDefaultLocationsPath,LocationLayout, THOR);
    EXPORT worldPeriodsCatalog := DATASET(worldPeriodsCatalogPath,CatalogLayout, THOR);


    EXPORT countiesGroupedPath := '~hpccsystems::covid19-test::file::public::metrics::counties_grouped.flat';
    EXPORT countiesAllPath := '~hpccsystems::covid19-test::file::public::metrics::counties_all.flat';
    EXPORT countiesLocationsCatalogPath := '~hpccsystems::covid19-test::file::public::metrics::counties_locations_catalog.flat';
    EXPORT countiesDefaultLocationsPath := '~hpccsystems::covid19-test::file::public::metrics::counties_locations_default.flat';
    EXPORT countiesPeriodsCatalogPath := '~hpccsystems::covid19-test::file::public::metrics::counties_periods_catalog.flat';

    EXPORT countiesGrouped := DATASET(countiesGroupedPath, GroupedLayout, THOR);
    EXPORT countiesAll := DATASET(countiesAllPath, Layout, THOR);
    EXPORT countiesLocationsCatalog := DATASET(countiesLocationsCatalogPath,CatalogLayout , THOR);
    EXPORT countiesDefaultLocations := DATASET(countiesDefaultLocationsPath,LocationLayout, THOR);
    EXPORT countiesPeriodsCatalog := DATASET(countiesPeriodsCatalogPath,CatalogLayout, THOR);



    end;


    EXPORT DailyMetrics := MODULE
    
        EXPORT statesPath := '~hpccsystems::covid19-test::file::public::metrics::daily_by_state.flat';
        EXPORT countriesPath := '~hpccsystems::covid19-test::file::public::metrics::daily_by_country.flat';
        EXPORT countiesPath := '~hpccsystems::covid19-test::file::public::metrics::daily_by_us_county.flat';  


        EXPORT statsrec := RECORD
            string location;
            unsigned4 date;
            DECIMAL8_2 cumcases;
            DECIMAL8_2 cumdeaths;
            DECIMAL8_2 cumhosp;
            DECIMAL8_2 tested;
            DECIMAL8_2 positive;
            DECIMAL8_2 negative;
        END;

        EXPORT Layout := RECORD (statsrec)
            unsigned8 id;
            integer8 period;
            DECIMAL8_2 prevcases;
            DECIMAL8_2 newcases;
            DECIMAL8_2 prevdeaths;
            DECIMAL8_2 newdeaths;
            real8 periodcgrowth;
            real8 periodmgrowth;
            DECIMAL8_2 active;
            DECIMAL8_2 prevactive;
            DECIMAL8_2 recovered;
            real8 imort;
        END;


        EXPORT states := DATASET(statesPath, layout, THOR);
        EXPORT counties := DATASET(countiesPath, layout, THOR);
        EXPORT countries := DATASET(countriesPath, layout, THOR);


    END;

END;