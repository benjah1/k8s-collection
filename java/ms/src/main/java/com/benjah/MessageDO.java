package com.benjah;

import java.util.Date;

public class MessageDO {

	private Integer id;

  private Integer msgId;

	private String message;

	private Date createTime;

	public MessageDO setId(Integer id) {
		this.id = id;
		return this;
	}

	public MessageDO setMsgId(Integer id) {
		this.msgId = id;
		return this;
	}

	public MessageDO setMessage(String msg) {
		this.message = msg;
		return this;
	}

	public MessageDO setCreateTime(Date createTime) {
		this.createTime = createTime;
		return this;
	}

	public Integer getMsgId() {
		return msgId;
	}

	public String getMessage() {
		return message;
	}

	public Date getCreateTime() {
		return createTime;
	}
}
