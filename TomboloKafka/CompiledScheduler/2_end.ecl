IMPORT kafka;
IMPORT STD;
IMPORT Util;

guid := DATASET('~covid19::kafka::guid', {STRING s}, FLAT);
failMsg := Util.sendMsg(instanceid :=guid[1].s, msg := '2_end failed');
outGUID := IF(EXISTS(guid), FAIL( 'EXCEPTION by 2_end'), OUTPUT(GUID[1].s , NAMED('GUID'))):FAILURE(EVALUATE(failMsg));
outGUID;






