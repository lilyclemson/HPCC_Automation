IMPORT kafka;
IMPORT STD;
IMPORT $.^.^.Util;
// Test scheduler on 4-way
// JSOn files
// {
//   "applicationId":"ebd584cd-06b8-4e84-8272-85f7f986d6d5",
//   "wuid":"W20200405-194353"
// }


guid := DATASET('~covid19::kafka::guid', {STRING s}, FLAT);
sendMsg := Util.sendMsg(instanceid := guid[1].s, msg := '0_Start is sending message');
// failMsg := Util.sendMsg(instanceid := guid[1].s, msg := '0_Start failed');
// IF(EXISTS(guid),  FAIL( 'EXCEPTION by 1_Clean: WUID ' + WORKUNIT),EVALUATE(sendMsg)):FAILURE(EVALUATE(failMsg));

sendMsg;
