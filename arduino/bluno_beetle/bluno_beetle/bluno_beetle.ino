#include <SoftwareSerial.h>   //Software Serial Port

#define TxD 4
#define RxD 5

#define DEBUG_ENABLED  1
int sensorPin = A0;
int sensorValue = 0;

SoftwareSerial blueToothSerial(RxD,TxD);

void setup()
{
    Serial.begin(115200);
    pinMode(RxD, INPUT);
    pinMode(TxD, OUTPUT);
}

void loop()
{
    char recvChar;
    char message;
    while(1)
    {
        sensorValue = analogRead(sensorPin);
        Serial.println(sensorValue);
        
        delay(200);
        if(blueToothSerial.available())
        {
          //check if there's any data sent from the remote bluetooth shield
          recvChar = blueToothSerial.read();
          Serial.println(recvChar);
        }
        if(Serial.available())
        {
          //check if there's any data sent from the local serial terminal, you can add the other applications here
          Serial.write(sensorValue);
        }
    }
}
