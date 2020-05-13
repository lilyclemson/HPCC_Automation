
IMPORT STD;
IMPORT Kafka;


EXPORT Util := MODULE

EXPORT applicationId:= 'ebd584cd-06b8-4e84-8272-85f7f986d6d5';
EXPORT defaultGUID := STD.Date.Today() + '' + STD.Date.CurrentTime(True);
EXPORT defaultTopic := 'Dataflow';
EXPORT defaultBroker := 'alalqalfapp01.risk.regn.net:9092';
EXPORT l_json := RECORD
  STRING applicationid;
  STRING wuid;
  STRING instanceId;
  STRING msg;
END;

EXPORT genInstanceID := FUNCTION
    guid := STD.Date.Today() + '' + STD.Date.CurrentTime(True);
    guidDS := DATASET(ROW({guid}, {STRING s}));
    RETURN OUTPUT( guidDS, , '~covid19::kafka::guid', OVERWRITE);
END;

EXPORT sendMsg(
              STRING broker = defaultBroker,
              STRING topic = defaultTopic,
              STRING appID = applicationId,
              STRING instanceid = defaultGUID,
              STRING msg = '') := FUNCTION


j :=  '{' + TOJSON(ROW({appID, WORKUNIT, instanceid, msg},l_json)) + '}';
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
              STRING instanceid = defaultGUID,
              STRING msg = 'FAIL') := FUNCTION


j :=  '{' + TOJSON(ROW({appID, WORKUNIT, instanceid, msg},l_json)) + '}';
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

END;