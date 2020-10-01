package com.benjah;

public class Message {

	private Integer id;

	public Message setId(Integer id) {
		this.id = id;
		return this;
	}

	public Integer getId() {
		return id;
	}

	@Override
	public String toString() {
		return "MyMessage{" +
						"id=" + id +
						'}';
	}
}
