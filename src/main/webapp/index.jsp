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
    <title>$Title$</title>
    <link rel="stylesheet" type="text/css" href="./styles/speech.css"/>
    <script type="text/javascript" src="./javascript/speech/gasSpeech.js"></script>
    <script src="./javascript/common/jquery/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCojRm8c3N0kGnXT5EstKMZsL25k2aKdks&callback=getLocation"
        async defer></script>
    <script language="javascript">
      function retrieve_zip(callback)
      {
      	try { if(!google) { google = 0; } } catch(err) { google = 0; } // Stupid Exceptions
      	if(navigator.geolocation) // FireFox/HTML5 GeoLocation
      	{
      		navigator.geolocation.getCurrentPosition(function(position)
      		{
      			zip_from_latlng(position.coords.latitude,position.coords.longitude,callback);
      		});
      	}
      	else if(google && google.gears) // Google Gears GeoLocation
      	{
      		var geloc = google.gears.factory.create('beta.geolocation');
      		geloc.getPermission();
      		geloc.getCurrentPosition(function(position)
      		{
      			zip_from_latlng(position.latitude,position.longitude,callback);
      		},function(err){});
      	}
      }
      function zip_from_latlng(latitude,longitude,callback)
      {
      	// Setup the Script using Geonames.org's WebService
      		var script = document.createElement("script");
      		script.src = "http://ws.geonames.org/findNearbyPostalCodesJSON?lat=" + latitude + "&lng=" + longitude +
              "&callback=" + callback + "&username=kuangchou";
      	// Run the Script
      		document.getElementsByTagName("head")[0].appendChild(script);
      }
      function example_callback(json)
      {
      	// Now we have the data!  If you want to just assume it's the 'closest' zipcode, we have that below:
      	zip = json.postalCodes[0].postalCode;
      	country = json.postalCodes[0].countryCode;
      	state = json.postalCodes[0].adminName1;
      	county = json.postalCodes[0].adminName2;
      	place = json.postalCodes[0].placeName;
      	alert(zip);
      }
     // retrieve_zip("example_callback"); // Alert the User's Zipcode

      function getLocation(){
            console.log("Entering getLocation()");
            if(navigator.geolocation){
            navigator.geolocation.getCurrentPosition(
            displayCurrentLocation,
            displayError,
            {
              maximumAge: 3000,
              timeout: 5000,
              enableHighAccuracy: true
            });
          }else{
            console.log("Oops, no geolocation support");
          }
            console.log("Exiting getLocation()");
          };
          function displayCurrentLocation(position){
            console.log("Entering displayCurrentLocation");
            var latitude = position.coords.latitude;
          var longitude = position.coords.longitude;
          console.log("Latitude " + latitude +" Longitude " + longitude);
          getAddressFromLatLang(latitude,longitude);
            console.log("Exiting displayCurrentLocation");
          }
         function  displayError(error){
          console.log("Entering ConsultantLocator.displayError()");
          var errorType = {
            0: "Unknown error",
            1: "Permission denied by user",
            2: "Position is not available",
            3: "Request time out"
          };
          var errorMessage = errorType[error.code];
          if(error.code == 0  || error.code == 2){
            errorMessage = errorMessage + "  " + error.message;
          }
          alert("Error Message " + errorMessage);
          console.log("Exiting ConsultantLocator.displayError()");
        }
          function getAddressFromLatLang(lat,lng){
            console.log("Entering getAddressFromLatLang()");
            var geocoder = new google.maps.Geocoder();
              var latLng = new google.maps.LatLng(lat, lng);
              geocoder.geocode( { 'latLng': latLng}, function(results, status) {
              console.log("After getting address");
              console.log(results);
              if (status == google.maps.GeocoderStatus.OK) {
                if (results[1]) {
                  console.log(results[1]);
                  alert(results[1].formatted_address);
                }
              }else{
                alert("Geocode was not successful for the following reason: " + status);
              }
              });
            console.log("Entering getAddressFromLatLang()");
          }
    </script>
  </head>
  <body>
    <div id="general"><strong>general</strong></div>
    <div id="address"><strong>address</strong></div>
    <div id="coords"><strong>coords</strong></div>

    <br/><br/>
    <form id="formId" method="get" action="https://www.google.com/search" target="_blank">
      Your Postal Code:
      <div class="speech">
        <input type="text" name="q" id="transcript" placeholder="Click Microphone to Speak" />
        <img onclick="startRecognition()" src="./images/speech/mic.gif" />
      </div>
      <br/><br/>
      <input type="submit" value="Get Local Gas Prices"/>
  	</form>

  </body>
</html>
