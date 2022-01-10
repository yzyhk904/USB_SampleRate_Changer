## USB (including a 3.5mm jack and an internal speaker) sample rate changer for Android devices on the fly

Under Magisk environment (<strong>"root name space mount mode" must be changed to "global"</strong> in the settings of Magisk Manager), this script changes the sample rate of the USB (including hardware offloading) audio class driver on Android devices on the fly like Bluetooth LDAC or Windows mixer for <q><em>avoiding annoying SRC (Sample Rate Conversion) distorsions</em></q>. This script signals the audioserver on the "global" mount name space to try to reaload an audio policy configuration file generated by this script with a specified sample rate and bit depth, so the "root name space mount mode" change is needed.

* Usage: `sh /sdcard/USB_SampleRate_Changer/USB_SampleRate_Changer.sh [--reset][--auto][--usb-only][--legacy][--offload][--bypass-offload][--safe][-safest] [--drc] [[44k|48k|88k|96k|176k|192k|353k|384k|706k|768k] [[16|24|32]]]`,

if you unpack the archive under "/sdcard" (Internal Storage). The arguments are a sample rate and a bit depth to which you want to change, respectively. Their default values are `44k` (sample rate: 44.1 kHz) and `32` (bit depth: 32 bits).

  - Options
    - `--reset`(without arguments): resets its previous execution results.
    - `--auto`: investigates device's environment and changes an audio policy configuration file appropriately in most situations. (default behavior)
    - `--usb-only`: changes a USB audio policy configuration file only.
    - `--legacy`: changes an audio policy configuration file for a Bluetooth audio legacy HAL (<em>/system/{lib,lib64}/hw/audio.a2dp.default.so</em>).
    - `--offload`: changes an audio policy configuration file for (USB & Bluetooth) hardware offloading. 
    - `--bypass-offload`: changes an audio policy configuration file for bypassing (USB & Bluetooth) hardware offloading and using a non- hardware offload USB & Bluetooth audio drivers while a 3.5mm jack and an internal speaker use a hardware offloading driver.
    - `--safe`: changes an audio policy configuration file for a Bluetooth audio legacy HAL, but keeps considerably traditional settings for an internal speaker and others.
    - `--safest`: changes an audio policy configuration file for a Bluetooth audio legacy HAL, but keeps most traditional settings for an internal speaker and others.
    - `--drc`: enables DRC (Dynamic Range Control or simply compression) for the purpose of comparison to usual DRC-less audio quality (not effective for --usb-only mode).

  - For typical example, `sh /sdcard/USB_SampleRate_Changer/USB_SampleRate_Changer.sh` automatically investigates your device and determines the audio policy configuration type ("offload" (including USB & Bluetooth), "bypass-offload" ("offload" except USB & Bluetooth), "legacy" ("bypass-offload" using a legacy Bluetooth module "a2dp"), "safe" (for non-offloading devices) and "safest" (for old devices). And this sets the sample rate and the bit depth of your device to be 44.1 kHz and 32 bits. If you want to set another sample rate and bit depth, please specify specific values.

* Note: "USB_SampleRate_Changer.sh" requires to unlock the USB audio class driver's limitation (upto 96kHz lock or 384kHz offload lock) if you want to specify greater than 96kHz or 384kHz (in case of USB hardware offloading, i.e. maybe hardware offload tunneling). See my companion magisk module ["usb-samplerate-unlocker"](https://github.com/Magisk-Modules-Alt-Repo/usb-samplerate-unlocker) for non- hardware offload drivers. Although you specify a high sample rate for this script execution, you cannot connect your device to a USB DAC with the sample rate unless the USB DAC supports the sample rate (the USB driver will limit the connecting sample rate downto its maximum sample rate).

* Tips 1: You can see the sample rate connecting to a USB DAC during music replaying by a command `cat /proc/asound/card1/pcm0p/sub0/hw_params` (for non- USB hardware offload drivers). You can also see mixer ("AudioFlinger") info by a command `dumpsys media.audio_flinger`. There are corresponding convenient scripts ("alsa-hw-params.sh" and "dumpsys-filtered.sh") in "extras" folder.

  - Usage:  `sh /sdcard/USB_SampleRate_Changer/extras/alsa-hw-params.sh`
    - outputs information of the ALSA audio driver for USB DAC's, 3.5mm Jack and internal speakers.

  - Usage:  `sh /sdcard/USB_SampleRate_Changer/extras/dumpsys-filtered.sh [--all][--help]`
     - outputs active peripheral's information from `dumpsys media.audio_flinger`. With `--all` option, this script outputs all perpheral's information from the command.

  - Usage:  `sh /sdcard/USB_SampleRate_Changer/extras/getConfig.sh [--all][--help]`
    - outputs breif information of the active audio policy configuration. With `--all` option, this script outputs all the information of the configuration.

  - Usage:  `sh /sdcard/USB_SampleRate_Changer/extras/change_resampling_quality.sh [--help] [--reset] [stop_band_dB [half_filter_length]]`
    - changes the resampling quality of AudioFlinger (the OS mixer). With "--reset" option, this script clears previous settings. "stop_band_dB" and "half_filter_length" specify stopband attenuation in dB and the number of input data needed before the current point (optional), respectively. AOSP default values are 98dB and 32 (3dB-cutoff: 100% to Nyquist frequency), but this script's default values are 140dB and 320 (3dB-cutoff: 91% to Nyquist frequency) as mastering quality values.

* Tips 2: "jitter-reducer.sh" in "extras" folder is an interactive tool derived from ["Hifi Maximizer"](https://github.com/yzyhk904/hifi-maximizer-mod) which could reduce jitter distortions in all digital audio outputs relating to SELinux mode, thermal controls, CPU&GPU governors, camera server, I/O scheduling, virtual memory, wifi suspension and audio effects framework. (Jitter distortions reduction is the very key to ultimate hifi audio quality)

  - Usage:  `sh /sdcard/USB_SampleRate_Changer/extras/jitter-reducer.sh [--selinux|++selinux][--thermal|++thermal][---governor|++governor][--camera|++camera][--io [scheduler [light | m-light | medium | boost]] | ++io][--vm|++vm][--wifi|++wifi][--all|++all][--effect|++effect][--status][--help]`

    - each "--" prefixed option except "--status" and "--help" options is an enabler for its corresponding jitter reducer, conversely each "++" prefixed option is an disabler for its corresponding jitter reducer. "--all" option is an alias of all "--" prefixed options except "--effect", "--status" and "--help" options, and also  "++all" option is an alias of all "++" prefixed options except "++effect".
    - "scheduler" specifys an I/O scheduler for I/O block devices (typically "deadline", "cfq" or "noop", but you may specify "*" for automatical best selection), and has optional four modes "light" (for warmer tone), "m-light" (for slightly warmer tone), "medium" (default) and "boost" (for clearer tone).
    - please remember that "--wifi" option is persistent even after reboot, but other options are not.

  - For most "hifi" example,  `sh /sdcard/USB_SampleRate_Changer/extras/jitter-reducer.sh --all --effect --status` enables all jitter reducers including effects framework one and outputs the jitter related statuses. For Bluetooth earphones, you may need to add `--io "*" boost` or `--io "*" m-light` option.  For DLNA transmitting, you may need to add `--io "*" boost` option. (If you use "AirMusic" to transmit audio data, I recommend to set around 4199 msec additional delay to reduce jitter distortion on the AirMusic panel to display target device(s).)

* Tips 3: Please disable "Adaptive battery" of adaptive preferences in the battery section and battery optimizations for following app's manually through the settings UI of Android OS (to lower less than 10Hz jitter making reverb like distortion). music (streaming) player apps, their licensing apps (if exist), equalizer apps (if exist), "bluetooth" (system app), "NFC Service" (system app; if exists), "Android Services Library" (system app), "Android Shared Library" (system app), "Android System" (system app), "System UI" (system app), "Active Edge Service" (system app; if exists), "Android Device Security Module" (system app; if exists), "crDroid System" (system app; if exists), "LineageOS System" (system app; if exists), launcher app, "Google Play Store" (system app), "Google Play Developer Services" (system app), "Styles & wallpaper" or the like (system app), {Lineage, crDroid, Arrow, etc.} themes app (system app; if exists), Navigation Bar app (system app; if exists), "AOSP panel" (system app; if exists), "OmniJaws" (system app; if exists), "OmniStyle" (system app; if exists), "Magisk", "PhhTrebleApp"(system app; if exists), keyboard app, kernel adiutors (if exist), etc. And also Disable "Digital Wellbeing" (system app; if it exists) itself or its battery optimizations (this is very harmfull for audio like camera servers).

* Tips 4: See also my magisk module ["audio-misc-settings"](https://github.com/yzyhk904/audio-misc-settings). This can increase the number of media volume steps to 100 steps and so on.

I recommend to use sManager (Script Manager) or the like for easiness.

## DISCLAIMER

* I am not responsible for any damage that may occur to your device, 
   so it is your own choice to attempt this script.

## Change logs

# v1.0
* Initial Release

# v1.1
* Recent higher sample rates added

# V1.2
* (USB) hardware offload support added (currently experimental)
* Bypass (USB) offload (using a non- USB hardware offload driver while the 3.5mm jack and internal speaker use a hardware offload driver) support added (currently experimental)

# V1.3
* Selinux enforcing mode bug fixed. Now this script can be used under both selinux enforcing and permissive modes

# V2.0
* Supported "disable a2dp hardware-offload" in dev. settings and PHH treble GSI's "force disable a2dp hardware-offload"
* Set an r_submix HAL to be 44.1kHz 16bit mode
* Added "auto" mode for investigating device's environment and guessing best settings

# V2.1
* ``--drc`` option added for the porpus of comparison to usual DRC-less audio quality

# V2.2
* extras/jitter-reducer.sh (a simplified version of my ["Hifi Maximizer"](https://github.com/yzyhk904/hifi-maximizer-mod)) added

# V2.3
* Enhanced extras/jitter-reducer.sh by adding a wifi jitter reducer which is especially effective for music streaming services (both online and offline), Pixel's and other high performance devices
* Cleaned up source codes

# V2.4
* Enhanced extras/jitter-reducer.sh by replacing the I/O jitter reducer with that of the hifi maximizer which uses "deadline" and "cfq" I/O schedulers and their optimized tunable values
