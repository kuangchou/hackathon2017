package com.lodenrogue.gasfinder;

import java.util.List;

class ExampleUsage {
	private static final String LAT = "40.7127";
	private static final String LONG = "-74.0059";
	private static final String API_KEY = "example";

	public static void main(String[] args) {
		/*
		 * Create a GasFinder object. Determine whether you're using the
		 * development mode. Then, supply your api key which can be
		 * found here: http://www.mygasfeed.com/keys/submit
		 */
		GasFinder gasFinder = new GasFinder(true, API_KEY);

		/*
		 * Get a list of all the stations nearby. Supply a latitude,
		 * longitude, search radius, fuel type, and sort type. The
		 * results are automatically sorted for you.
		 */
		List<Station> stations = gasFinder.getStationsNearby(LAT, LONG, 2, FuelType.REG, SortType.PRICE);

		/*
		 * Do something with the data.
		 */
		for (Station s : stations) {
			System.out.println(s);
		}
	}

}
