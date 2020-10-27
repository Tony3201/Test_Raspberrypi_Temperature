

#For the test, Pi ZW;Pi3b,Pi4,was work very well. #
#########################################################################
# Name: Test_Rpi_Temperature_By_GCC
# Version: 0.2
# Author: tony3201
# Created Time: Oct 27,2020		
#########################################################################

#include <stdio.h>

int main(int argc, char *argv[])
{
   FILE *fp;

   int temp = 0;
   fp = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
   fscanf(fp, "%d", &temp);
   printf(">> CPU Temp: %.2f°C\n", temp / 1000.0);
   fclose(fp);

   return 0;
}

