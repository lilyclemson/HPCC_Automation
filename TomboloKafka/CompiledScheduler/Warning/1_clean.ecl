IMPORT STD;
IMPORT Util;
IMPORT Kafka;

guid := DATASET('~covid19::kafka::guid', {STRING s}, FLAT);
sendMsg1 := Util.sendMsg(instanceid :=guid[1].s, msg := '1_clean completed with WARNING');

sendMsg := ASSERT(guid[1].s = '',  'Assert Failed: Total cases reported as 0'):SUCCESS(EVALUATE(sendMsg1));

sendMsg;
