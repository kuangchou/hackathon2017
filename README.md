# GasPrice Web Application
Java Web Application For Gas Price Nearby

This application will automatic get user's geo location and use it to retrieve most current gas prices neerby.

The application will display a google Map and make the gas station nearby with gas price mark. Also, user can fill in a
postal code to retrieve other location's gas price.

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
