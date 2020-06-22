# Simplifying the dev workflow

## Motivation

You may have found that building & testing the kernel requires tedious manual effort. Here are some steps to simplify the workflow, so that we can focus on kernel hacking. 

You should proceed only after having verified your hardware setup is correct. 

## Is it safe to ...?

#### Unplug the micro SD card (uSD) when Rpi3 is powered on?

Safe. Doing so when Rpi3 runs a full-fledged OS, e.g. Raspbian OS, may corrupt data because the OS caches data in memory. Our tiny kernel does not attempt to write any data to the micro SD. 

#### Plug in a micro SD card when Rpi3 is powered on?

Safe. Then you can power-cycle the Rpi3 so 

#### Disconnect the serial cable when Rpi3 is on?

Safe. If your Rpi3 is powered over the serial cable -- no state to lose. If you Rpi3 is powered over micro USB: why disconnect the serial cable frequently? 

#### Unplug micro SD from PC without "ejecting/unmounting" from the PC OS?

I advise against it. 

## The manual workflow

(Once) Connect Rpi3 and PC via the serial cable. 

Repeat: 

1. Modify our kernel source if needed. Make kernel8.img
1. Unplug uSD from Rpi3. Rpi3 does not have to be powered off. 
1. Plug in uSD to the card reader on PC. 
1. Copy kernel8.img to the uSD's boot partition. Overwrite the previous kernel8.img.
1. Eject/umount uSD from PC. 
1. Plug in uSD to Rpi3.
1. Power-cycle Rpi3. Wait for the kernel to execute. See output. Reason about it. 

## The automated workflow

Depending on your PC OS: 

Linux: there's a Python script you can adapt. 

Windows (WSL):

OSX: 









