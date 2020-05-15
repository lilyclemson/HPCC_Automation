IMPORT kafka;
IMPORT STD;
IMPORT tomboloKafka.Util;

// Test scheduler on 4-way
// JSOn files
// {
//   "applicationId":"ebd584cd-06b8-4e84-8272-85f7f986d6d5",
//   "wuid":"W20200405-194353"
// }


OUTPUT('step 0'):SUCCESS(NOTIFY(EVENT('step1', 'success')));
