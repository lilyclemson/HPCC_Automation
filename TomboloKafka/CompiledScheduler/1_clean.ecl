IMPORT STD;
IMPORT Util;
IMPORT Kafka;

guid := DATASET('~covid19::kafka::guid', {STRING s}, FLAT);
sendMsg1 := Util.sendMsg(instanceid :=guid[1].s, msg := '1_clean is sending msg');
sendMsg2 := Util.sendMsg(instanceid :=guid[1].s, msg := '1_clean completed with a Warning');


// sendMsg := ASSERT(guid[1].s = '',  'WARNING by 1_clean'):SUCCESS(EVALUATE(sendMsg2));
sendMsg := ASSERT(guid[1].s = '',  'Assert Failed: Total cases reported as 0'):SUCCESS(EVALUATE(sendMsg2));

sendMsg;

