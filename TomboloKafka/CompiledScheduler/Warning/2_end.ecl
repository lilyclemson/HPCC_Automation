IMPORT kafka;
IMPORT STD;
IMPORT Util;

guid := DATASET('~covid19::kafka::guid', {STRING s}, FLAT);


successMsg := Util.sendMsg(instanceid :=guid[1].s, msg := '2_end finished');
OUTPUT(guid, NAMED('instanceid')):SUCCESS(EVALUATE(successMsg));





