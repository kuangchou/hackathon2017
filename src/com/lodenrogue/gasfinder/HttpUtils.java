package com.lodenrogue.gasfinder;

import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

final class HttpUtils {
	public static final String DEV_URL_PRE = "http://devapi.mygasfeed.com/";
	public static final String URL_PRE = "http://api.mygasfeed.com/";
	public static final String DEV_API_KEY = "rfej9napna";

	private static final String URL_GET_NEARBY = "stations/radius/";
	private static final String URL_GET_STATION_HISTORY = "locations/pricehistory/";

	private HttpUtils() {

	}

	public static String getStationHistory(String urlPre, String apiKey, String stationID) {
		StringBuilder url = new StringBuilder();
		url.append(urlPre + URL_GET_STATION_HISTORY);
		url.append(stationID + "/");
		url.append(apiKey + ".json");

		return getResponse(apiKey, url.toString());
	}

	public static String getStationsNearby(String urlPre, String apiKey, String latitude, String longitude, int radius, FuelType fuelType, SortType sortType) {
		StringBuilder url = new StringBuilder();
		url.append(urlPre + URL_GET_NEARBY);
		url.append(latitude + "/");
		url.append(longitude + "/");
		url.append(String.valueOf(radius) + "/");
		url.append(fuelType.toString().toLowerCase(Locale.US) + "/");
		url.append(sortType.toString().toLowerCase(Locale.US) + "/");
		url.append(apiKey + ".json");

		return getResponse(apiKey, url.toString());
	}

	private static String getResponse(String apiKey, String url) {
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("", ""));

		String response = JSONParser.makeHttpRequest(url.toString(), Method.GET, params);

		try {
			response = response.substring(response.indexOf("{\"status\""));
		}
		catch (StringIndexOutOfBoundsException e) {
			throw new InvalidParameterException("apiKey: " + apiKey + " is invalid.");
		}
		return response;
	}

}
