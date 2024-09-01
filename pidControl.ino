#include "PinChangeInterrupt.h"
#include <Wire.h>
#include <math.h>

class PID{
  private:
    double Kp;
    double Ki;
    double input;
    double output;
    double error;
    double error_int = 0;
    unsigned long pid_time = 0;
    
  public:
    double setpoint;
    
    PID(double Kp, double Ki, double setpoint) :
    Kp(Kp), Ki(Ki), setpoint(setpoint){}
  
    double update(double input){
      error = input - setpoint;
      if (input !=0 ){
        error_int += error * (micros() - pid_time) / 1e6;        
      }
      pid_time = micros();
      output = Kp * error + Ki * error_int;
      return output;
    }
};

class Motor{
  private:
    const double rpp = 1/1320.;
    volatile byte C1_state = LOW;
    volatile byte C2_state = LOW;
    unsigned long time_motor = 0;
    const double Vdead = 1.4;
    const double Vmax = 12;
    const double v2byte = 255 / (Vmax - Vdead);
    PID pid;
    double V_out;
    
  public:
    const byte pinC1;
    const byte pinC2;
    const byte pinM1;
    const byte pinM2;
    const byte pinPWM;
    volatile int dist = 0;
    double prev_dist = 0.;
    double speed;
    
    Motor (const byte pinC1, const byte pinC2, const byte pinM1, const byte pinM2, const byte pinPWM) :
    pinC1(pinC1), pinC2(pinC2), pinM1(pinM1), pinM2(pinM2), pinPWM(pinPWM), pid(15,10,1) {
      pinMode(pinC1, INPUT_PULLUP);
      pinMode(pinC2, INPUT_PULLUP);
      pinMode(pinM1, OUTPUT);
      pinMode(pinM2, OUTPUT);
      pinMode(pinPWM, OUTPUT);
    }
    
    void update() {
      speed = ((dist - prev_dist)*1e6)/(micros() - time_motor);
      prev_dist = dist;
      time_motor = micros();
    }
    
    void setSetPoint(double setpoint){
      pid.setpoint = setpoint;
    }
    
    void setVoltage(double Vin){
      if (Vin < 0){
        digitalWrite(pinM2,LOW);
        digitalWrite(pinM1,HIGH);
      }
      else{
        digitalWrite(pinM1,LOW);
        digitalWrite(pinM2,HIGH);
      }
      if (Vin == 0){
        analogWrite(pinPWM,0);
      }
      else{
        analogWrite(pinPWM,min(int((abs(Vin)+Vdead)*v2byte),255));
      }
    }
    
    void speedPID(){
      V_out = pid.update(speed);
      Serial.println(V_out);
      setVoltage(V_out);
    }
    
    void C1change() {
      C1_state = digitalRead(pinC1);
      if (C1_state == C2_state){
        dist -= 1;
      }
      else{
        dist += 1;
      }
    }
    
    void C2change() {
      C2_state = digitalRead(pinC2);
      if (C1_state == C2_state){
        dist += 1;
      }
      else{
        dist -= 1;
      }
    }
    
};

Motor motor1(8,9,11,12,10);
unsigned long time_init = 0;
unsigned int count = 0;
bool end = false;

void setup() {
  Serial.begin(115200);
  
  attachPCINT(digitalPinToPCINT(motor1.pinC1), M1C1ISR, CHANGE);
  attachPCINT(digitalPinToPCINT(motor1.pinC2), M1C2ISR, CHANGE);
}

void loop() {
  count += 1;
  motor1.update();
  Serial.print(motor1.dist);
  Serial.print(" ");
  Serial.println(micros()/100);
  if((millis() - time_init) > 200 & !end){  
    motor1.setVoltage(-1);
  }
  delay(7);
  
  if((millis() - time_init) > 5000 & !end){  
    motor1.setVoltage(0);
    Serial.println(count);
    while (true){
  
    }
  }
}

void M1C1ISR() {
  motor1.C1change();
}

void M1C2ISR() {
  motor1.C2change();
}
