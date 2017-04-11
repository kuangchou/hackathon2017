
// HTML5 Speech Recognition API
window.SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

function say(messageToSay) {
	var msg = new SpeechSynthesisUtterance(messageToSay);
	window.speechSynthesis.speak(msg);
}

if (!SpeechRecognition) {
	var messageToSay = "Speech Recognition is not supported by this browser!";
	say(messageToSay);
	alert(messageToSay);
}

function startRecognition() {
	var messageToSay = "Please Speak your postal code!";
	say(messageToSay);
	
	var recognition = new SpeechRecognition();
	recognition.continuous = false;
	recognition.interimResults = false;

	recognition.lang = "en-US";

	try {
		recognition.start();
		console.log('Recognition started');
	} catch(ex) {
		console.log('Recognition error: ' + ex.message);
	}

	recognition.onresult = function(e) {
		document.getElementById('transcript').value = e.results[0][0].transcript;					 
		console.log('Recognition result processed');

    document.getElementById('formId').submit();
    console.log('Form submitted');

		recognition.stop();
		console.log('Recognition stopped');
	};

	recognition.onerror = function(e) {
		console.log("Recognition error!");
		recognition.stop();
		console.log('Recognition stopped');
	};

	recognition.onnomatch = function(e) {
		console.log("Recognition no match!");
		recognition.stop();
		console.log('Recognition stopped');
	};
}

function Station(name, stationArea, price, time) {
	this.name = name;
	this.stationArea = stationArea;
	this.price = price;
	this.time = time;
}

function getStations(){
	var station1 = new Station("Petro Canada", "Richmond", "138.9 cents", "4 hours ago");
	var station2 = new Station("Shell", "Richmond", "148.9 cents", "3 hours ago");
	var station3 = new Station("Chevron", "Vancouver", "149.9 cents", "2 hours ago");
	var stations = new Array();
	stations.push(station1);
	stations.push(station2);
	stations.push(station3);
	return stations;
}

speakStations(getStations());

function speakStations(stations) {
  if(stations === null || stations.length === 0) {
    return;
  }
	for (var i = 0; i < stations.length; i++) {
		var messageToSay = "Station " + (i+1) + " " + stations[i].name + "at " + stations[i].stationArea + " The price is " + stations[i].price + " reported " + stations[i].time;
		say(messageToSay);
	}

}