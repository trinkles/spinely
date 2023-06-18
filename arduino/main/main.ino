#include <WiFi.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>

/* Wifi needs */

const char* ssid = "ssid";
const char* password = "pass";

const char* server = "localIP";
const int serverPort = 80; //default

const char* url = "/spinelytest.php"; 

/* Calibration needs */
struct Calibration {
    String type;
    float min;
    float max;
    float avg;
};

Calibration calibrationData[] = {
    {"cervical_angle", 0.0, 0.0, 0.0},
    {"thoracic_angle", 0.0, 0.0, 0.0},
    {"lumbar_angle", 0.0, 0.0, 0.0},
    {"left_midAxLine_angle", 0.0, 0.0, 0.0},
    {"right_midAxLine_angle", 0.0, 0.0, 0.0}
};

bool updateCalibration = false; // Set to true to update calibration, false to skip calibration

/* Monitoring needs */
struct Monitoring {
  String type;
  float value;
};

Monitoring monitoringData[] = {
  {"cervical", 0},
  {"thoracic", 0},
  {"lumbar", 0},
  {"leftmidAx", 0},
  {"rightmidAx", 0}
};

int postureStatus = 0; // 0 for not determined, 1 for proper, -1 for improper


 /* Initializing sensor pins and iteration */
const int sensorPin[] = {32,33,39,34,25};
float sensVal[5]; // reading from Arduino

float forAvg[5][10] = {0}; // 2d array to store sensor values for each second

/* From calibrated flex value to angle - called later on */
float mapValue(float value, float inMin, float inMax, float outMin, float outMax) {
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

/* Calibration and mapping */

void calibration() {
  unsigned long startMillis = millis();
  unsigned long currentMillis = startMillis;

  int secondsCounter = 0; // Counter for seconds

  // Initialize the minimum and maximum values with the first sensor reading
  for (int sensor = 0; sensor < 5; sensor++) {
    sensVal[sensor] = analogRead(sensorPin[sensor]);
    calibrationData[sensor].min = sensVal[sensor];
    calibrationData[sensor].max = sensVal[sensor];
  }

  while ((unsigned long)(currentMillis - startMillis) < 10000) { // 10 seconds in total
    if (secondsCounter < 10) { // Execute for the first 10 seconds
      for (int sensor = 0; sensor < 5; sensor++) {
        sensVal[sensor] = analogRead(sensorPin[sensor]);
        forAvg[sensor][secondsCounter] = sensVal[sensor];

        // Update the minimum and maximum values
        if (sensVal[sensor] < calibrationData[sensor].min) {
          calibrationData[sensor].min = sensVal[sensor];
        }
        if (sensVal[sensor] > calibrationData[sensor].max) {
          calibrationData[sensor].max = sensVal[sensor];
        }
      }
      secondsCounter++;
    }
    currentMillis = millis();
  }

  // Calculate average values for calibration and map them to angles
  for (int sensor = 0; sensor < 5; sensor++) {
    float sum = 0;
    for (int value = 0; value < 10; value++) {
      sum += forAvg[sensor][value];
    }
    calibrationData[sensor].avg = sum / 10;

    // Map the calibration values to angles
    calibrationData[sensor].avg = mapValue(calibrationData[sensor].avg, 0, 4095, 0, 90);
    calibrationData[sensor].min = mapValue(calibrationData[sensor].min, 0, 4095, 0, 90);
    calibrationData[sensor].max = mapValue(calibrationData[sensor].max, 0, 4095, 0, 90);
  }
}

/* Monitoring and mapping */

void monitoring() {
  unsigned long startMillis = millis();
  unsigned long currentMillis = startMillis;

  int secondsCounter = 0; // Counter for seconds
  int sensorProper = 0; // counter if each section angle is within range
  int isProper = 0; // proper posture after 10-second monitoring
  int isImproper = 0; // improper posture after 10-second monitoring

  while ((unsigned long)(currentMillis - startMillis) < 10000) { // 10 seconds in total
    if (secondsCounter < 10) { // Execute for the first 10 seconds
      for (int sensor = 0; sensor < 5; sensor++) {
        sensVal[sensor] = analogRead(sensorPin[sensor]);
        forAvg[sensor][secondsCounter] = sensVal[sensor];
      }
      secondsCounter++;
    }
    currentMillis = millis();
  }

  // Calculate average values for monitoring
  for (int sensor = 0; sensor < 5; sensor++) {
    float sum = 0;
    for (int value = 0; value < 10; value++) {
      sum += forAvg[sensor][value];
    }
    monitoringData[sensor].value = sum / 10;
    Serial.println(monitoringData[sensor].value);

    // Map the monitoring values to angles
    monitoringData[sensor].value = mapValue(monitoringData[sensor].value, 0, 4095, 0, 90);
  }
    
  // sensor within acceptable range from calibration
  for (int sensor = 0; sensor < 5; sensor++) {
    // check if monitoringVal is within the range or matches the average value
    if (monitoringData[sensor].value >= calibrationData[sensor].min && monitoringData[sensor].value <= calibrationData[sensor].max || monitoringData[sensor].value == calibrationData[sensor].avg) {
        sensorProper++; // sensor angle within the acceptable range or matches the average value
    }
  }
    
  if (sensorProper==5){
      isProper = 1;
      sensorProper=0;
  } else {
      isImproper = 1;
  }

}

/* JSONifying final angle readings */
void serializeData(JsonDocument& doc) {

  JsonObject calibrationDataObject = doc.createNestedObject("calibration");
  for (int i = 0; i < 5; i++) {
    JsonObject sensorData = calibrationDataObject.createNestedObject(calibrationData[i].type.c_str());
    sensorData["type"] = calibrationData[i].type;
    sensorData["min"] = calibrationData[i].min;
    sensorData["max"] = calibrationData[i].max;
    sensorData["avg"] = calibrationData[i].avg;

  }

  // parent JSON object for monitoring
  JsonObject jsonRoot = doc.to<JsonObject>();

  // monitoring object with sensor data
  JsonObject monitoringDataObject = jsonRoot.createNestedObject("monitoring");
  for (int i = 0; i < 5; i++) {
      monitoringDataObject[monitoringData[i].type] = monitoringData[i].value;
  }

  jsonRoot["postureStatus"] = postureStatus;

  // serialize posture status to a string
  String jsonString;
  serializeJson(jsonRoot, jsonString);

}

/* Finally, Setup */

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {

  delay(1000);
    
  // Perform calibration
  if (updateCalibration){ 
      calibration();
      updateCalibration=false;
  }
  monitoring();

  // Create a JSON document
  const size_t capacity = JSON_OBJECT_SIZE(3) + 5 * (JSON_OBJECT_SIZE(2) + 32) + 9 * (JSON_OBJECT_SIZE(2) + 32);
  DynamicJsonDocument doc(capacity);

  // Serialize the data to JSON
  serializeData(doc);

  // Convert the JSON document to a string
  String jsonString;
  serializeJson(doc, jsonString);

  // Print the JSON string
  Serial.println(jsonString);

  // Delay or perform other operations
  delay(1000);
    
  WiFiClient client;
  if (client.connect(server, serverPort)) {
    Serial.println("Connected to server");
    Serial.println("Sending request to server");

    // Send the HTTP POST request with the JSON payload
    client.println("POST " + String(url) + " HTTP/1.1");
    client.println("Host: " + String(server));
    client.println("Content-Type: application/json");
    client.println("Content-Length: " + String(jsonString.length()));
    client.println("Connection: close");
    client.println();
    client.println(jsonString);

    while (client.connected()) {
      if (client.available()) {
        String line = client.readStringUntil('\r');
        Serial.println(line);
      }
    }
    client.stop();
    Serial.println("Request completed");
  } else {
    Serial.println("Failed to connect to server");
  }
}
