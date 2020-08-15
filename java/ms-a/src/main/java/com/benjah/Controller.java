package com.benjah;

import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.concurrent.ExecutionException;

@RestController
public class Controller {

	@Autowired
  private Producer producer;


	@RequestMapping("/ping")
	public String ping() {
		return "pond";
	}

	@RequestMapping("/send")
	public String send() throws ExecutionException, InterruptedException {
		Integer date = (int) new Date().getTime()/1000;
		producer.sendMessage(date);
		return "Success";
	}

}
