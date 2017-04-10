package com.lodenrogue.gasfinder;

import org.json.JSONException;
import org.json.JSONObject;

public class Station {
	private final float regPrice;
	private final float midPrice;
	private final float prePrice;
	private float dieselPrice;
	private final String address;
	private final String id;
	private final String lat;
	private final String lng;
	private final String stationName;
	private final String distance;

	public Station(JSONObject station) throws JSONException {
		regPrice = getFloat(station.getString("reg_price"), -1f);
		midPrice = getFloat(station.getString("mid_price"), -1f);
		prePrice = getFloat(station.getString("pre_price"), -1f);
		dieselPrice = getFloat(station.getString("diesel_price"), -1f);

		address = station.getString("address");
		id = station.getString("id");
		lat = station.getString("lat");
		lng = station.getString("lng");

		stationName = station.get("station").toString();
		distance = station.getString("distance");
	}

	private float getFloat(String strPrice, float defaultValue) {
		float price = 0;
		try {
			price = Float.valueOf(strPrice);
		}
		catch (NumberFormatException e) {
			price = defaultValue;
		}
		return price;
	}

	public float getRegPrice() {
		return regPrice;
	}

	public float getMidPrice() {
		return midPrice;
	}

	public float getPrePrice() {
		return prePrice;
	}

	public float getDieselPrice() {
		return dieselPrice;
	}

	public String getAddress() {
		return address;
	}
	
	public String getID(){
		return id;
	}

	public String getLatitude() {
		return lat;
	}

	public String getLongitude() {
		return lng;
	}

	public String getStationName() {
		return stationName;
	}

	public String getDistance() {
		return distance;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("---------------------------------\n");
		sb.append("Station: " + stationName + "\n");
		sb.append("Distance: " + distance + "\n");
		sb.append("Latitude: " + lat + "\n");
		sb.append("Longitude: " + lng + "\n");
		sb.append("Address: " + address + "\n");
		sb.append("ID: " + id + "\n");
		sb.append("Regular: " + regPrice + "\n");
		sb.append("Mid: " + midPrice + "\n");
		sb.append("Premium: " + prePrice + "\n");
		sb.append("Diesel: " + dieselPrice + "\n");
		sb.append("---------------------------------\n");
		return sb.toString();
	}
}
