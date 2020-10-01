package com.benjah;

import java.util.Date;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class PingController {

	@RequestMapping("/ping")
	public String ping() {
		return "pond";
	}
}
