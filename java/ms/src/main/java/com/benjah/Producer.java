package com.benjah;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Value;

import javax.annotation.Resource;
import java.util.concurrent.ExecutionException;

@Component
public class Producer {

		@Value("${spring.kafka.topic}")
    private String topic;

    @Resource
    private KafkaTemplate<Object, Object> kafkaTemplate;

    public SendResult sendMessage(Integer id) throws ExecutionException, InterruptedException {
        Message message = new Message();
        message.setId(id);
        return kafkaTemplate.send(topic, message).get();
    }
}
