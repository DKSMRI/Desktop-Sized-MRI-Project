#include "C:\Program Files (x86)\Arduino\libraries\Pwm01\pwm01.h"

int xmst = 1;
int running=1;
int nsteps=12;
int curstep=0;
int dc =0;
int NTR=128;
int tp=0;
long starttime;
int tdata[1024]={1};

#define LineEnd '!'


int sequence[13][8]=
{  
  {   
    0,          0,        0,       0,       0,       0,       0,    0         }
  ,
  {   
    200,        0,        0,       5,       0,       0,       0,    200       }
  ,
  {   
    1000,       0,        0,       5,       1,       0,       0,    1200      }
  ,
  {   
    200,        0,        0,       0,       0,       0,       0,    1400      }
  ,
  {   
    200,        0,        0,       6,       0,       0,       0,    1600      }
  ,
  {   
    500,        0,        0,       6,       0,       0,       0,    2100      }
  ,
  {   
    200,        1,        3,       0,       0,       0,       0,    2300      }
  ,
  {   
    2000,       1,        3,       0,       0,       0,       0,    4300      }
  ,
  {   
    200,        0,        0,       0,       0,       0,       0,    4500      }
  ,
  {   
    200,        2,        0,       0,       0,       0,       0,    4700      }
  ,
  {  
    4000,        2,        0,       0,       0,       1,       0,    8700      }
  ,
  {  
    200,         0,        0,       0,       0,       0,       0,    8900      }
  ,
  {  
    10000,       0,        0,       0,       0,       0,       1,    18900     }
  ,
};



int GT[7][3]=
{  

  {     
    0,     0,        0   }
  ,
  {     
    1,    -255,    -255    }
  ,
  {     
    2,     255,     255    }
  ,
  {     
    3,    -255,    255   }
  ,
  {     
    4,     0,        0   }
  ,
  {     
    5,     255,     255    }
  ,
  {     
    6,    -255,   -255   }
  ,
};  

int Grpin=7;
int Gppin=9;
int Gspin=8;
int Pulse = 6;
int trnum=1;
int dtime; 
long k;
long gg;
void setup()                    
{

    uint32_t  pwm_duty = 2048;
    uint32_t  pwm_freq2 = 108000;

    // Set PWM Resolution
    pwm_set_resolution(16);  

    // Setup PWM Once (Up to two unique frequencies allowed
    //-----------------------------------------------------    
    pwm_setup( 6, pwm_freq2, 2);  // Pin 6 freq set to "pwm_freq1" on clock A
    pwm_setup( 7, pwm_freq2, 2);  // Pin 7 freq set to "pwm_freq2" on clock B
    pwm_setup( 8, pwm_freq2, 2);  // Pin 8 freq set to "pwm_freq2" on clock B
    pwm_setup( 9, pwm_freq2, 2);  // Pin 9 freq set to "pwm_freq2" on clock B
        pwm_write_duty( 7, pwm_duty );  // 50% duty cycle on Pin 7
   pwm_write_duty( 8, pwm_duty );  // 50% duty cycle on Pin 8
    pwm_write_duty( 9, pwm_duty );  // 50% duty cycle on Pin 9
 analogWriteResolution(12);  // set the analog output resolution to 12 bit (4096 levels)
  analogReadResolution(12);   // set the analog input resolution to 12 bit 
  Serial.begin(115200);
  //pinMode(Grpin, OUTPUT);   // sets the pin as output
  //pinMode(Gppin, OUTPUT);   // sets the pin as output
  //pinMode(Gspin, OUTPUT);   // sets the pin as output
 //pinMode(Pulse, OUTPUT);   // sets the pin as output
 
 //Serial.println("       ");
  //Serial.println("*******");
  
  Serial.begin(115200);
Serial.println('a');
char a = 'b';

while (a != 'a')
{
  a = Serial.read();

}
}



void loop()                    
{
  char inputBuffer[256];
  int inputLength = 0;


if (curstep == 0)
  starttime=micros();
  


if (trnum == 1)
 k = micros();
 

  long curtime=micros()-starttime;

  if (curtime>sequence[curstep][7])
  {   curstep=curstep+1;
   
  }
  if (curstep>nsteps)
  {     
    starttime=micros();
    trnum = trnum + 1;
 
    curstep = 0;
     curtime=micros()-starttime;
    if (trnum > NTR)
     { Serial.println(2);
        gg = micros() - k;
       // Serial.println(gg);
      trnum = 1;
      while(1){}
      starttime = micros();
        long curtime=micros()-starttime;
     }
    if (curtime>sequence[curstep][7])
      curstep=curstep+1;
  }
  float tf=1-trnum/NTR;    // fraction of the way through the table




  if (running==1)
  {

    // check Gr

    if (sequence[curstep][1]!=sequence[curstep-1][1])
    {
      dtime=-(curtime-sequence[curstep][7]);
      int ramp=sequence[curstep][0];

      int g1=GT[ sequence[curstep-1][1] ][1];
      int g2=GT[ sequence[curstep-1][1] ][2];

      int ga=g1*tf+g2*(1-tf);

      int g3=GT[ sequence[curstep][1] ][1];
      int g4=GT[ sequence[curstep][1] ][2];

      int gb=g3*tf+g4*(1-tf);
      int temp=ga*dtime/ramp  + gb*(1-dtime/ramp);

      pwm_write_duty(Grpin, map(temp,-255,255,0,65530));
   
    }
    else

      pwm_write_duty(Grpin,map(GT[ sequence[curstep][1] ][1]*tf + GT[ sequence[curstep][1] ][2]*(1-tf),-255,255,0,65530));

    // check Gp

    if (sequence[curstep][2]!=sequence[curstep-1][2])
    {
      dtime=-(curtime-sequence[curstep][7]);
      int ramp=sequence[curstep][0];

      int g1=GT[ sequence[curstep-1][2] ][1];
      int g2=GT[ sequence[curstep-1][2] ][2];

      int ga=g1*tf+g2*(1-tf);

      int g3=GT[ sequence[curstep][2] ][1];
      int g4=GT[ sequence[curstep][2] ][2];

      int gb=g3*tf+g4*(1-tf);
      long temp=ga*dtime/ramp  + gb*(1-dtime/ramp);
 
      pwm_write_duty(Gppin, map(temp,-255,255,0,65530));
  

    }
    else
   
      {pwm_write_duty(Gppin,map(GT[ sequence[curstep][2] ][1]*tf + GT[ sequence[curstep][2] ][2]*(1-tf),-255,255,0,65530));
 
}
    // Check Gs
    if (sequence[curstep][3]!=sequence[curstep-1][3])
    {
      dtime=-(curtime-sequence[curstep][7]);
      int ramp=sequence[curstep][0];

      int g1=GT[ sequence[curstep-1][3] ][1];
      int g2=GT[ sequence[curstep-1][3] ][2];

      int ga=g1*tf+g2*(1-tf);

      int g3=GT[ sequence[curstep][3] ][1];
      int g4=GT[ sequence[curstep][3] ][2];

      int gb=g3*tf+g4*(1-tf);
      int temp=ga*dtime/ramp  + gb*(1-dtime/ramp);

      pwm_write_duty(Gspin, map(temp,-255,255,0,65530));

    }
    else
      {  
        pwm_write_duty(Gspin,map(GT[ sequence[curstep][3] ][1]*tf + GT[ sequence[curstep][3] ][2]*(1-tf),-255,255,0,65530));

      }


// Pulse 
    if (sequence[curstep][4]==1)
    {
  
  long arga = sin(curtime*2*3.14159*10000)*255;
  analogWrite(DAC0, arga);  

    }

// Data Read 
    if (sequence[curstep][5]==1){  long sttime = micros();
while(xmst != 126){
  if(micros()-sttime>=40*(xmst+1)){
tdata[xmst] = analogRead(A0);
//MNOP(1);
//tddata[xmst] = micros()-sttime;
xmst++;
  }
}
long ctime = micros()-sttime;
 

    }

// Data Send 
    if (sequence[curstep][6]==1){
      if (dc!=0){
    for(int x = 0; x < dc + 1; x++){
     Serial.println(tdata[x]);
     }
     dc = 0;
     int tdata[500] = {1};
   }

  }


}
}

