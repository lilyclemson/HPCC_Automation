
IMPORT STD;
IMPORT Kafka;


EXPORT Util := MODULE

EXPORT applicationId:= '40650e2a-da00-4192-9fd9-36cf13ab3094';
EXPORT guidFilePath := '~covid19::kafka::guid';
EXPORT defaultGUID :=  DATASET(guidFilePath, {STRING s}, FLAT)[1].s;
EXPORT defaultTopic := 'Dataflow';
EXPORT defaultBroker := '40.71.7.106:9092';
EXPORT l_json := RECORD
  STRING applicationid;
  STRING wuid;
  STRING instanceId;
  STRING msg;
END;

EXPORT genInstanceID := FUNCTION
    guid := STD.Date.Today() + '' + STD.Date.CurrentTime(True);
    guidDS := DATASET(ROW({guid}, {STRING s}));
    RETURN OUTPUT( guidDS, , guidFilePath, OVERWRITE);
END;

EXPORT sendMsg(
              STRING broker = defaultBroker,
              STRING topic = defaultTopic,
              STRING appID = applicationId,
              STRING wuid = WORKUNIT,
              STRING instanceid = defaultGUID,
              STRING msg = '') := FUNCTION


j :=  '{' + TOJSON(ROW({appID, wuid, instanceid, msg},l_json)) + '}';
kafkaMsg := DATASET([{j}], {STRING line});

p := kafka.KafkaPublisher( topic, broker );
sending := p.PublishMessage(kafkaMsg[1].line);
o := OUTPUT(kafkaMsg );

RETURN WHEN(sending,o);

END;


EXPORT sendFailMsg(
              STRING broker = defaultBroker,
              STRING topic = defaultTopic,
              STRING appID = applicationId,
              STRING wuid = WORKUNIT,
              STRING instanceid = defaultGUID,
              STRING msg = 'FAIL') := FUNCTION


j :=  '{' + TOJSON(ROW({appID, wuid, instanceid, msg},l_json)) + '}';
kafkaMsg := DATASET([{j}], {STRING line});

p := kafka.KafkaPublisher( topic, broker );
sending := p.PublishMessage(kafkaMsg[1].line);
o := OUTPUT(kafkaMsg );

RETURN WHEN(sending,o);
END;

EXPORT sendSuccessMsg(
              STRING broker = defaultBroker,
              STRING topic = defaultTopic,
              STRING appID = applicationId,
              STRING instanceid = defaultGUID,
              STRING msg = 'SUCCESS') := FUNCTION


j :=  '{' + TOJSON(ROW({appID, WORKUNIT, instanceid, msg},l_json)) + '}';
kafkaMsg := DATASET([{j}], {STRING line});

p := kafka.KafkaPublisher( topic, broker );
sending := p.PublishMessage(kafkaMsg[1].line);
o := OUTPUT(kafkaMsg );

RETURN WHEN(sending,o);

END;


EXPORT sendWarningMsg(
              STRING broker = defaultBroker,
              STRING topic = defaultTopic,
              STRING appID = applicationId,
              STRING instanceid = defaultGUID,
              STRING msg = 'WARNING') := FUNCTION


j :=  '{' + TOJSON(ROW({appID, WORKUNIT, instanceid, msg},l_json)) + '}';
kafkaMsg := DATASET([{j}], {STRING line});

p := kafka.KafkaPublisher( topic, broker );
sending := p.PublishMessage(kafkaMsg[1].line);
o := OUTPUT(kafkaMsg );

RETURN WHEN(sending,o);

END;

END;