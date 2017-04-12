    <%--
  Created by IntelliJ IDEA.
  User: kuang
  Date: 4/10/2017
  Time: 4:33 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Gas Price</title>
  <meta name="viewport" content="initial-scale=1.0">
  <meta charset="utf-8">
  <style>
    /* Always set the map height explicitly to define the size of the div
     * element that contains the map. */
    #map {
      height: 95%;
    }

    /* Optional: Makes the sample page fill the window. */
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
  </style>

  <script src="./javascript/common/jquery/jquery-1.11.1.min.js" type="text/javascript"></script>
  <script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js">
      </script>
  <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCojRm8c3N0kGnXT5EstKMZsL25k2aKdks&callback=getLocation"
          async defer></script>
  <script language="javascript">
    function retrieve_zip(callback) {
      try {
        if (!google) {
          google = 0;
        }
      }
      catch (err) {
        google = 0;
      } // Stupid Exceptions
      if (navigator.geolocation) // FireFox/HTML5 GeoLocation
      {
        navigator.geolocation.getCurrentPosition(function (position) {
          zip_from_latlng(position.coords.latitude, position.coords.longitude, callback);
        });
      }
      else if (google && google.gears) // Google Gears GeoLocation
      {
        var geloc = google.gears.factory.create('beta.geolocation');
        geloc.getPermission();
        geloc.getCurrentPosition(function (position) {
          zip_from_latlng(position.latitude, position.longitude, callback);
        }, function (err) {
        });
      }
    }
    function zip_from_latlng(latitude, longitude, callback) {
      // Setup the Script using Geonames.org's WebService
      var script = document.createElement("script");
      script.src =
          "http://ws.geonames.org/findNearbyPostalCodesJSON?lat=" + latitude + "&lng=" + longitude + "&callback=" +
          callback + "&username=kuangchou";
      // Run the Script
      document.getElementsByTagName("head")[0].appendChild(script);
    }
    function example_callback(json) {
      // Now we have the data!  If you want to just assume it's the 'closest' zipcode, we have that below:
      zip = json.postalCodes[0].postalCode;
      country = json.postalCodes[0].countryCode;
      state = json.postalCodes[0].adminName1;
      county = json.postalCodes[0].adminName2;
      place = json.postalCodes[0].placeName;
      alert(zip);
    }
    // retrieve_zip("example_callback"); // Alert the User's Zipcode

    function getLocation() {
      console.log("Entering getLocation()");
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(displayCurrentLocation, displayError, {
          maximumAge: 3000,
          timeout: 5000,
          enableHighAccuracy: true
        });
      }
      else {
        console.log("Oops, no geolocation support");
      }
      console.log("Exiting getLocation()");
    }

    function displayCurrentLocation(position) {
      console.log("Entering displayCurrentLocation");
      var latitude = position.coords.latitude;
      var longitude = position.coords.longitude;
      console.log("Latitude " + latitude + " Longitude " + longitude);
      getAddressFromLatLang(latitude, longitude);
      console.log("Exiting displayCurrentLocation");
    }

    function displayError(error) {
      console.log("Entering ConsultantLocator.displayError()");
      var errorType = {
        0: "Unknown error",
        1: "Permission denied by user",
        2: "Position is not available",
        3: "Request time out"
      };
      var errorMessage = errorType[error.code];
      if (error.code == 0 || error.code == 2) {
        errorMessage = errorMessage + "  " + error.message;
      }
      alert("Error Message " + errorMessage);
      console.log("Exiting ConsultantLocator.displayError()");
    }

    function getAddressFromLatLang(lat, lng) {
      console.log("Entering getAddressFromLatLang()");
      var geocoder = new google.maps.Geocoder();
      var latLng = new google.maps.LatLng(lat, lng);
      geocoder.geocode({'latLng': latLng}, function (results, status) {
        console.log("After getting address");
        console.log(results);
        if (status == google.maps.GeocoderStatus.OK) {
          if (results[1]) {
            console.log(results[1]);
            //alert(results[1].formatted_address);
          }
        }
        else {
          alert("Geocode was not successful for the following reason: " + status);
        }
      });
      console.log("Entering getAddressFromLatLang()");
      var curLoc = {
        lat: lat,
        lng: lng
      };
      var map = new google.maps.Map(document.getElementById('map'), {
        center: curLoc,
        scrollwheel: false,
        zoom: 14
      });
      var marker = new google.maps.Marker({
        position: curLoc,
        map: map
      });
      getGeoFromAddress(['4011 Francis Rd & No 1 Rd', 'Esso 7991 No 1 Rd & Blundell Rd', 'Chevron 5900 Westminster Hwy & No 2 Rd'],
          ['Petro-Canada station1', 'Esso station2', 'Chevron station3'], map);
    }

    function getGeoFromAddress(addressList, contentString, map) {
      var geocoder = new google.maps.Geocoder();
      var locations = [];
      console.log("Entering getGeoFromAddress()");
      var markers = [];
      var labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      var addressLen = addressList.length;
      for (var i = 0; i < addressLen; i++) {
        var address = addressList[i];
        geocoder.geocode({ 'address': address}, function(results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            var latitude = results[0].geometry.location.lat();
            var longitude = results[0].geometry.location.lng();
            var location = { lat: latitude, lng: longitude };
            locations.push(location);
            console.log(">>>> Location: " + location);
            var marker = new google.maps.Marker({
                      position: location,
                      label: labels[(locations.length - 1) % labels.length]
                    });
            var infowindow = new google.maps.InfoWindow({
                      content: contentString[locations.length - 1]
                    });
            marker.addListener('mouseover', function() {
                      infowindow.open(map, marker);
                    });
            marker.addListener('mouseout', function() {
                                  infowindow.close();
                                });
            markers.push(marker);
            if (locations.length === addressLen) {
              locateGasStation(markers, map);
            }
          }
        });
      }
      console.log("End getGeoFromAddress()");
    }

    function locateGasStation(markers, map) {

      // Add a marker clusterer to manage the markers.
      var markerCluster = new MarkerClusterer(map, markers,
          {imagePath: './images'});

    }
  </script>
</head>
<body>
<form>Postal Code: <input type="text" name="PostalCode"></form>
<div id="map"></div>
</body>
</html>
