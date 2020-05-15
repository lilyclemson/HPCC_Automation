IMPORT kafka;


p := kafka.KafkaPublisher('Dataflow', brokers := '40.71.7.106:9092');

message := 'hello world';
p.PublishMessage(message);