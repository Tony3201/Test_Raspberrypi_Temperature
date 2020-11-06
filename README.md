#Test_Raspberrypi_Temperature_By_GCC

1.make
  
  gcc temp.c -o temp

2.move to bin
  
  sudo mv ./temp /usr/local/bin/   
  
 ##some OS the path is  " /usr/bin/ "path for the other os,such as openwrt.
  
3.command line test;done
  
  user:~# temp
  >>CPU Temp: 45.08°C


