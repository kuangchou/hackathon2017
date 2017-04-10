package com.lodenrogue.gasfinder;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

class Factory {

	private Factory() {

	}

	public static List<Station> getStations(JSONArray stationsArray) throws JSONException {
		List<Station> stations = new ArrayList<Station>();

		for (int i = 0; i < stationsArray.length(); i++) {
			JSONObject station = stationsArray.getJSONObject(i);
			stations.add(new Station(station));
		}
		return stations;
	}

}
