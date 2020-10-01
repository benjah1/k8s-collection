package com.benjah;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.concurrent.ExecutionException;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.http.HttpHeaders;

@RefreshScope
@RestController
public class Controller {

	@Value("${feature.toggle.restapi}")
 	private Boolean enabled;

	@Autowired
	private Producer producer;

  private Logger logger = LoggerFactory.getLogger(getClass());

	@RequestMapping("/send")
	public String send() throws ExecutionException, InterruptedException, NoHandlerFoundException {
		if (!enabled) {
			throw new NoHandlerFoundException("GET", "/send", new HttpHeaders());
    }

    logger.info("[onRequest][id:{}]", Thread.currentThread().getId());
		Integer date = (int) new Date().getTime()/1000;
		producer.sendMessage(date);
		return "Success";
	}
}
