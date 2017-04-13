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
      height: 82%;
    }

    /* Optional: Makes the sample page fill the window. */
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
  </style>

  <script src="./javascript/common/jquery/jquery-1.11.1.min.js" type="text/javascript"></script>
  <script src="./javascript/common/js-cookie/js.cookie-2.0.2.min.js" type="text/javascript"></script>
  <link rel="stylesheet" type="text/css" href="./styles/speech.css"/>
  <link rel="stylesheet" type="text/css" href="./styles/loading.css"/>
  <script type="text/javascript" src="./javascript/speech/gasSpeech.js"></script>
  <script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js">
      </script>
  <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCojRm8c3N0kGnXT5EstKMZsL25k2aKdks&callback=getLocation"
          async defer></script>
  <script language="javascript">
//    function retrieve_zip(callback) {
//      try {
//        if (!google) {
//          google = 0;
//        }
//      }
//      catch (err) {
//        google = 0;
//      } // Stupid Exceptions
//      if (navigator.geolocation) // FireFox/HTML5 GeoLocation
//      {
//        navigator.geolocation.getCurrentPosition(function (position) {
//          zip_from_latlng(position.coords.latitude, position.coords.longitude, callback);
//        });
//      }
//      else if (google && google.gears) // Google Gears GeoLocation
//      {
//        var geloc = google.gears.factory.create('beta.geolocation');
//        geloc.getPermission();
//        geloc.getCurrentPosition(function (position) {
//          zip_from_latlng(position.latitude, position.longitude, callback);
//        }, function (err) {
//        });
//      }
//    }
//    function zip_from_latlng(latitude, longitude, callback) {
//      // Setup the Script using Geonames.org's WebService
//      var script = document.createElement("script");
//      script.src =
//          "http://ws.geonames.org/findNearbyPostalCodesJSON?lat=" + latitude + "&lng=" + longitude + "&callback=" +
//          callback + "&username=kuangchou";
//      // Run the Script
//      document.getElementsByTagName("head")[0].appendChild(script);
//    }
//    function example_callback(json) {
//      // Now we have the data!  If you want to just assume it's the 'closest' zipcode, we have that below:
//      zip = json.postalCodes[0].postalCode;
//      country = json.postalCodes[0].countryCode;
//      state = json.postalCodes[0].adminName1;
//      county = json.postalCodes[0].adminName2;
//      place = json.postalCodes[0].placeName;
//      alert(zip);
//    }
    // retrieve_zip("example_callback"); // Alert the User's Zipcode

    var googleLocation = Cookies.get('googleLocations');
    var HISTORY_LOCATION_VALUES = googleLocation !== undefined ? JSON.parse(googleLocation) : [];
    var googleAddress = Cookies.get('googleAddress');
    var HISTORY_LOCATION = googleAddress !== undefined ? JSON.parse(googleAddress) : [];

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

    function getStationsFromAddress(address) {
      $('#searchMask').show();
      if (HISTORY_LOCATION_VALUES[HISTORY_LOCATION.indexOf(address)]) {
        var location = HISTORY_LOCATION_VALUES[HISTORY_LOCATION.indexOf(address)];
        getAddressFromLatLang(location.lat, location.lng);
      }
      else {
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({'address': address}, function (results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            var latitude = results[0].geometry.location.lat();
            var longitude = results[0].geometry.location.lng();
            var location = {
              lat: latitude,
              lng: longitude
            };
            updateCookeis(address, location);
            getAddressFromLatLang(location.lat, location.lng);
            console.log(">>>> Location: " + address + ' Location: ' + location.lat + ", " + location.lng);
          }
          else {
            console.log('Error on : ' + address + ' Status: ' + status);
          }
        });
      }
    }

    var map;
    var markers = [];
    var markerCluster;
    function getAddressFromLatLang(lat, lng) {
      console.log("Entering getAddressFromLatLang()");
      var geocoder = new google.maps.Geocoder();
      var latLng = new google.maps.LatLng(lat, lng);
      var curLoc = {
        lat: lat,
        lng: lng
      };
      if (!map) {
        map = new google.maps.Map(document.getElementById('map'), {
          center: curLoc,
          scrollwheel: true,
          zoom: 12
        });
      }
      else {
        map.setCenter(curLoc);
      }
      if (markerCluster) {
        markerCluster.clearMarkers();
        deleteMarkers();
      }
      geocoder.geocode({'latLng': latLng}, function (results, status) {
        console.log("After getting address");
        console.log(results);
        if (status == google.maps.GeocoderStatus.OK) {
          if (results[1]) {
            console.log(results[0].address_components[6].short_name);
            //alert(results[1].formatted_address);
            $.ajax({
              url: 'http://localhost:8081/gasprice', //results[0].address_components[6].short_name,
              type: 'GET',
              dataType: 'json',
              data: {
                zipCode: results[0].address_components[6].short_name
              },
              success: function(result) {
                if (result && result !== "") {
                  getGasStationInfo(result);
                }
              },
              error: function(result) {
                console.log('>>> Error ');
              }
            })
          }
        }
        else {
          alert("Geocode was not successful for the following reason: " + status);
        }
      });
      console.log("Entering getAddressFromLatLang()");
    }
    var gasStationDescription = [];
    var searchLocation = [];
    var searchLen = 0;
    var curIndex = 0;
    var curAddressList;
    var overLimitedLocation;
    function getGasStationInfo(locationList) {
      var locations = [];
      gasStationDescription = [];
      var stations = [];
      var station;
      var stationName = "";
      for (var i = 0; i < locationList.length; i++) {
        stationName = "";
        var stationInfo = locationList[i].station.split(' ');
        var j = 0;
        for (j = 0; j < stationInfo.length; j++) {
          if ($.isNumeric(stationInfo[j])) {
            break;
          }
          else {
            stationName += stationInfo[j];
          }
        }
        stationInfo.splice(0, j);
        locations.push(stationInfo.join(' '));
        gasStationDescription.push('Station: ' + locationList[i].station + '<br/>Price: ' + locationList[i].price +
            '<br/>Area: ' + locationList[i].area + '<br/>Last Updated: ' + locationList[i].lastUpdated);
        station = new Station(stationName, locationList[i].area, locationList[i].price, locationList[i].lastUpdated);
        stations.push(station);
      }
      speakStations(stations);
      searchLocation = [];
      searchLen = locations.length;
      curAddressList = locations;
      curIndex = 0;
      getGoogleLocation();
    }

    function getGeoFromAddress() {
      if (searchLocation.length === searchLen) {
        locateGasStation();
      }
      else if (searchLocation[curIndex] === undefined) {
        setTimeout(getGeoFromAddress, 100);
      }
      else {
        // Go to next one
        curIndex++;
        getGoogleLocation();
      }
    }
    function getGoogleLocation() {
      console.log("Entering getGeoFromAddress()");
      var address = curAddressList[curIndex];
      if (HISTORY_LOCATION_VALUES[HISTORY_LOCATION.indexOf(address)]) {
        searchLocation.push(HISTORY_LOCATION_VALUES[HISTORY_LOCATION.indexOf(address)]);
        getGeoFromAddress();
      }
      else {
        getGeoInfo(address);
      }
      console.log("End getGeoFromAddress()");
    }

    function getGeoInfo(address) {
      var geocoder = new google.maps.Geocoder();
      geocoder.geocode({'address': address}, function (results, status) {
        if (status === google.maps.GeocoderStatus.OK) {
          var latitude = results[0].geometry.location.lat();
          var longitude = results[0].geometry.location.lng();
          var location = {
            lat: latitude,
            lng: longitude
          };
          updateCookeis(address, location);
          searchLocation.push(location);
          console.log(">>>> Location: " + address + ' Location: ' + location.lat + ", " + location.lng);
          getGeoFromAddress();
        }
        else if (status === google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
          console.log('Error on : ' + address + ' Status: ' + status);
          overLimitedLocation = address;
          if (overLimitedLocation == address) {
            searchLocation.push({
              lat: -1,
              lng: -1
            });
          }
          setTimeout(getGeoFromAddress, 500);
        }
        else {
          searchLocation.push({lat: -1, lng: -1});
          getGeoFromAddress();
        }
      });
    }

    function locateGasStation() {
      var labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      for (var i = 0; i < searchLocation.length; i++) {
        var marker = new google.maps.Marker({
          position: searchLocation[i],
          label: labels[i % labels.length]
        });
        var content = gasStationDescription[i];
        var infowindow = new google.maps.InfoWindow({
          content: content
        });
        google.maps.event.addListener(marker, 'mouseover', (function (marker, content, infowindow) {
          return function() {
            infowindow.setContent(content);
            infowindow.open(map, marker);
          };
        })(marker, content, infowindow));
        google.maps.event.addListener(marker, 'mouseout', (function (marker, content, infowindow) {
          return function() {
            infowindow.close();
          };
        })(marker, content, infowindow));
        markers.push(marker);
      }
      // Add a marker clusterer to manage the markers.
      markerCluster = new MarkerClusterer(map, markers, {imagePath: './images/m'});
      $('#searchMask').hide();
    }

    function setMapOnAll(aMap) {
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(aMap);
      }
    }

    function deleteMarkers() {
      setMapOnAll(null);
      markers = [];
    }

    function updateCookeis(address, location) {
      if (HISTORY_LOCATION.indexOf(address) === -1) {
        HISTORY_LOCATION.push(address);
        HISTORY_LOCATION_VALUES.push(location);
      }
      var date = new Date();
      date.setTime(date.getTime() + (24 * 60 * 60 *1000));
      document.cookie = 'googleLocations=' + JSON.stringify(HISTORY_LOCATION_VALUES) + '; expires=' + date.toGMTString() +
          '; path=/';
      document.cookie = 'googleAddress=' + JSON.stringify(HISTORY_LOCATION) + '; expires=' + date.toGMTString() +
                '; path=/';
    }
  </script>
</head>
<body style="overflow: hidden;">
<div id="searchMask" class="lmask"></div>
<form id="formId" method="get" action="" target="_blank">
	Your Location:
  <div class="speech">
		<input type="text" name="q" id="transcript" placeholder="Click Microphone to Speak" />
		<img style='margin-top: -5px;' onclick="startRecognition()" src="./images/speech/mic.gif" />
	  </div>
  <input type="button" value="Get Local Gas Prices" onclick="getStationsFromAddress(document.forms[0].elements['q'].value);"/>
</form>
<div id="map"></div>
</body>
</html>
