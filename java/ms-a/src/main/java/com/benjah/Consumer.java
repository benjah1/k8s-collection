package com.benjah;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.Date;

@Component
public class Consumer {

		@Value("${spring.kafka.topic}")
    private String topic;

    @Autowired
    private MessageDao messageDao;

    private AtomicInteger count = new AtomicInteger(0);

    private Logger logger = LoggerFactory.getLogger(getClass());

    @KafkaListener(topics = "#{'${spring.kafka.topic}'.split(',')}",
            groupId = "consumer-group-" + "#{'${spring.kafka.topic}'.split(',')}")
    public void onMessage(Message message) {
        logger.info("[onMessage][id:{}, msg：{}]", Thread.currentThread().getId(), message);

				MessageDO msg = new MessageDO().setMsgId(message.getId())
						.setMessage(message.toString()).setCreateTime(new Date());
        messageDao.insert(msg);
    }
}

/*
import org.springframework.beans.factory.annotation.Autowired;

    @Autowired
    DataSource dataSource;
*/
