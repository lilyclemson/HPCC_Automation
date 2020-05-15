IMPORT STD;
IMPORT $.^.^.Util;
IMPORT Kafka;

guid := DATASET('~covid19::kafka::guid', {STRING s}, FLAT);
sendMsg1 := Util.sendMsg(instanceid :=guid[1].s, msg := '1_clean is sending msg');
sendMsg1;

