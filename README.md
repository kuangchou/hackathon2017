# GasFinderJavaAPI
Java API for myGasFeed

Example:

    /*
		 * Create a GasFinder object. Determine whether you're using the
		 * development mode. Then, supply your api key which can be
		 * found here: http://www.mygasfeed.com/keys/submit
		 */
		GasFinder gasFinder = new GasFinder(false, API_KEY);

		/*
		 * Get a list of all the stations nearby. Supply a latitude,
		 * longitude, search radius, fuel type, and sort type. The
		 * results are automatically sorted for you.
		 */
		List<Station> stations = gasFinder.getStationsNearby(latitude, longitude, radius, FuelType.REG, SortType.PRICE);

		/*
		 * Do something with the data.
		 */
		for (Station s : stations) {
			System.out.println(s);
		}
