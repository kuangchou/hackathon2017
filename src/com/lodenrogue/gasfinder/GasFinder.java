package com.lodenrogue.gasfinder;

import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class GasFinder {
	private boolean devMode;
	public final String API_KEY;

	public GasFinder(boolean devMode, String apiKey) {
		this.devMode = devMode;
		this.API_KEY = apiKey;
	}

	/**
	 * Returns a list of gas stations matching the supplied parameters
	 * within a search radius.
	 * 
	 * @param latitude Latitude coordinate at the center of the search
	 *                radius.
	 * @param longitude Longitude coordinate at the center of the search
	 *                radius.
	 * @param radius Distance (in miles) for the search radius.
	 * @param fuelType The FuelType chosen to sort results.
	 * @param sortType The SortType for the result order.
	 * @return List of Station.
	 */

	public List<Station> getStationsNearby(String latitude, String longitude, int radius, FuelType fuelType, SortType sortType) {
		String workApiKey = devMode ? HttpUtils.DEV_API_KEY : API_KEY;
		String urlPre = devMode ? HttpUtils.DEV_URL_PRE : HttpUtils.URL_PRE;

		String json = HttpUtils.getStationsNearby(urlPre, workApiKey, latitude, longitude, radius, fuelType, sortType);
		JSONObject jsonObject = new JSONObject(json);
		JSONArray stationsArray = jsonObject.getJSONArray("stations");

		return Factory.getStations(stationsArray);
	}

	public void setDevelopmentMode(boolean developmentMode) {
		this.devMode = developmentMode;
	}
}
