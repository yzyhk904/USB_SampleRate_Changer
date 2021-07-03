## USB sample rate changer for Android devices on the fly

Under Magisk environment ("root name space mount mode" must be changed to "global"), this script changes the sample rate of the USB audio class driver on Android devices on the fly like Bluetooth LDAC or Windows.

* Usage: sh /sdcard/USB_SampleRate_Changer/USB_SampleRate_Changer.sh [[44k|48k|88k|96k|176k|192k|353k|384k|706k|768k] [[16|24|32]]]

  if you unpacked the archive under "/sdcard" (Internal Storage).
* Note: "USB_SampleRate_Changer.sh" requires to unlock the USB audio class driver's limitation (96kHz lock) if you like to specify greater than 96kHz. See my companion repository "usb-samplerate-unlocker".

I recommend to use Script Manager or like for easiness.

## DISCLAIMER

* I am not responsible for any damage that may occur to your device, 
   so it is your own choice to attempt this script.

## Change logs

# v1.0
* Initial Release

# v1.1
* Recent higher sample rates added
