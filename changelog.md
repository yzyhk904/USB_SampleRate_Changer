## Change logs

# v3.0.3
* Added a script which enables "DRC" with max samplerate detection

# v3.0.2
* Added an exception for Asus Zenfone 9 to change its Bluetooth HAL form "bluetooth"  to "bluetooth_qti"
* Added a cheapies-48kHz-cheapest resampler

# v3.0.1
* Added "--safest-auto" mode for automatic max. USB samplerate detection for old devices
* Fixed to adjust volume curve table links in an audio policy configuration template dynamically for avoiding miss-linking

# v3.0.0
* Added 7.0 audio policy configuration supports
* Added automatic max. sample rate detection (for USB devices) supports

# v2.8.7
* Added a workaround for Pineapple devices for no using the AOSP bluetooth module temporary
* Added a support for Tensor G4 (zuma pro)
* Tuned I/O scheduler tunables especially for "resampling-for-cheapies"

# v2.8.6
* Changed the default Bluetooth sample rate of "safer" templates from 44.1 kHz to 48 kHz for Am@zon music SD (Opus 48 kHz & 192 kbps vbr stereo) tracks
* Adjusted jitter optimizations and others for YTM's format change from AAC (141; 44.1 kHz & 256 kbps cbr stereo) to Opus (774; 48 kHz & 256 kbps vbr stereo)

# v2.8.5
* Changed dirty_ratio and dirty_background_ration to be 100 to reduce jitter
* Changed adjustSoC_mq for A14 and later clover not to round I/O parameters
* Adjusted cfq I/O parameters for SDM69x devices
* Added a new resampler script specially tuned for LDAC BT and DAC's under $30 devices both having large non-linear amp. distortion in "Usage Samples/Resampling"

# v2.8.4
* Changed read ahead buffer sizes from 16960 kB to 17000 kB to reduce I/O jitter
* Adjusted NrRequests of I/O scheduling
* Adjusted "extras/jitter-reducer.sh" for Galaxy S4 (A12)
* Added mock equipment filters (in-DAC over-sampling filters and a mastering tool resampler) in "Usage Samples/Resampling"

# v2.8.3
* Fixed io-scheduler reverting (++io option) for Galaxy S4 (A12)
* Fixed thermal-jitter-reducer in "extras/jitter-reducer.sh" (killing vendor.thermal-engine)
* Fixed Pixel7's default USB sample rate limiter (96kHz -> 192kHz) for adapting to a recent change
* Added a workaround for recent Pixel Firmwares (not to reboot when superuser resetprop'ing over props modified through system.prop of a magisk module)
* Reorganized "Usage Samples"

# v2.8.2
* Fixed for Pixel 8's
* Fixed Usage samples for executing on KernelSU ("exec su" to "su" for correct expansion of shell variables)

# v2.8.1
* Tuned "extras/jitter-reducer.sh" for reducing I/O scheduling jitter on Tensor devices
* Fixed a bug for "--force-bluetooth-qti" option
* Tuned "extras/jitter-reducer.sh" for reducing CFQ I/O scheduling jitter on Qcomm devices

# v2.8.0
* Tuned "extras/jitter-reducer.sh" for reducing I/O scheduling jitter on most devices
* Added "Usage_Samples" to easily execute every script with its typical parameters on file explorers with some sh script execution capability like "mixplorer"

# v2.7.3
* Fixed "extras/jitter-reducer.sh" to change "performance" governor of GPU without fail
* Tuned "extras/jitter-reducer.sh" for reducing I/O scheduling jitter on Tensor devices

# v2.7.2
* Tuned "extras/jitter-reducer.sh" for reducing I/O scheduling jitter, especially for Tensor devices
* Fixed a bug for Magisk 26.x

# v2.7.1
* Optimized "extras/jitter-reducer.sh" for reducing I/O scheduling jitter
* "extras/jitter-reducer.sh" now confirms and sets the cpu scaling max freq to its available max (sometimes the scaling max freq has been lowered before by a controller on some devices)
* Removed "raw" mixers from template files
* Fixed and adjusted "extras/jitter-reducer.sh" for Tensor devices (e.g., GPU max freq and the mq-deadline scheduler)
* Added supports to Tensor devices; Tensor specific --offload-hifi-playback mode (USB 96kHz or 192kHz fixed for non- hires. music while 48kHz did on stock ROMs) and --bypass-offload-safer mode (only 44kHz, 48kHz, 96kHz and 192kHz are available by using Tensor device's offload driver)
* Note: Audio outputs of stock Tensor devices work by 48kHz & float mode for non-hires. music, 96kHz & 32bit for hires. one, and exceptionally 44.1kHz & 16bit for AAC music files (compressed offload feature) without third party proprietary USB drivers. Till now, the usbv2 HAL driver cannot work at all after AOC (new USB Direct Access feature) was introduced. Tensor's hardware offload driver wouldn't change its sample rate except 44.1kHz, 48kHz, 96kHz and 192kHz (float and 32bit int format).

# v2.7.0
* Optimized "extras/jitter-reducer.sh" for reducing I/O scheduling jitter
* Added a support for "sysbta" (System Wide Bluetooth Hal) of recent GSI's and "bluetooth_qti" (experimental)

# v2.6.5
* Optimized "extras/jitter-reducer.sh" for reducing I/O scheduling jitter
* Added extras/dumpsys-bluetooth-filtered.sh command for displaying the active codec information

# v2.6.4
* Optimized "extras/jitter-reducer.sh" for reducing I/O scheduling jitter
* Fixed bugs related to bluetooth SCO Headset (Hands-free) when "--bypass-offload-safer" modes
* Improved "extras/dumpsys-filtered.sh" for bluetooth SCO

# v2.6.3
* Adjusted bluetooth device formats for letting Am*zon music app to output 44kHz & 32bit float format

Note: The Am*zon app determines its output format (of its internal resampler) for bluetooth by looking at the bluetooth device format (picking up the max sample rate if multiple rates specified) in the audio policy configuration XML file on each phone, e.g. outputting 48kHz & 16bit for 48kHz & 16bit phones, 96kHz & 16bit for 96kHz & 16bit phones, 44.1kHz & 32bit float for 44.1kHz & 24bit or 32bit (used by my script). Please choose 44.1kHz & 32bit (or the possible largest bits) in developer settings.

If you like to specify the Am*zon's output format on recent phones, specify "--offload-hifi-playback" and "96k 32", "48k 24", etc. This option changes the initial format of bluetooth devices only, so you can change the current format through developer settings afterward.

# v2.6.2
* Added "--offload-direct" mode for comparing usual (non-a2dp hardware offload) mixer modes to "direct_pcm" and "compressed_offload" modes with&without DRC, especially for bluetooth audio

Note: "direct_pcm" and "compressed_offload" modes cannot avoid default DRC on Qcomm devices. As some recent custom ROM's sometimes reverse on/off of the DRC switch, please confirm the difference by your ears.

# v2.6.1
* Added a bypass offload safer mode for recent MTK devices
* Changed the default behavior to prefer bypass offload safer modes to bypass offload modes for limiting effect only on USB audio

# v2.6.0
* Added support for the usbv2 HAL module
* Tuned for LDAC TWS's (use extras/jitter-reducer.sh --io * medium).

Note: For crDroid Alioth users, try "--bypass-offload-safer 96k 32" or "--offload-hifi-playback 48k 24" option.

# v2.5.5
* Tuned "extras/jitter-reducer.sh" with respect to tunables for "mq-deadline", "kyber" and "none" I/O scheduler (latest kernel common schedulers?)
* Added forgotten wired phone entries in "bypass-offload-safer" mode
* Fixed for the Nyx kernel 4.19 (expiration tunables of its mq-deadline scheduler were changed in 10msec resolution from 3msec)
* Disabled the work queue power efficient mode for reducing jitter if possible (especially for the Nyx kernel and other latest ones)

# v2.5.4
* Fixed a telephone audio configuration issue on Qcomm SoC Android 12 caused by a hal version mismatch
* Added "--bypass-offload-safer" option for keeping the sample rate and the bit depth of internal speakers and a 3.5mm jack to be 48kHz 16/24bit

# v2.5.3
* Tuned "extras/jitter-reducer.sh" for Bluetooth devices, USB DAC's and DLNA receivers
    "extras/jitter-reducer.sh --all --io deadline medium" for Bluetooth devices
    "extras/jitter-reducer.sh --all --io deadline boost" for USB DAC's and DLNA receivers

# v2.5.2
* Added a workaround for Android 12 SELinux bug w.r.t. "ro.audio.usb.period_us" property
* Tuned kernel tunables for clearer audio quality

# v2.5.0
* Added extras/change-resampling-quality.sh (to reduce resampling distortion) and extras/change-usb-period.sh (to reduce the jitter of a PLL in a DAC)directly)
* Tuned kernel tunables by assuming an audio scheduling tunable "vendor.audio.adm.buffering.ms" to be "2" (please set this property by my magisk modules ["usb-samplerate-unlocker"](https://github.com/Magisk-Modules-Alt-Repo/usb-samplerate-unlocker) and/or ["audio-misc-settings"](https://github.com/Magisk-Modules-Alt-Repo/audio-misc-settings))

# v2.4.11
* extras/jitter-reducer.sh:  
    1. Disabled the Android doze itself for reducing jitter considerably unless disabling battery optimizations of app's  
    2. Tuned kernel tunables for recent Qcomm and MTK devices  

* USB_SampleRate_Changer.sh:  
    1. Added an option specifying "float" bit depth.  

* Fixed an audioserver hang-up after setprop restart on A12 low performance devices (by sending a SIGHUP signal to the server)
* Added resampling parameter examples in README

# v2.4.10
* Tuned for POCO F3 (SD870) on phh GSI's because I abandoned tuning for custom ROM's on POCO F3 except phh GSI's
* Tuned for SD845 devices; Perhaps also SD855 & SD865 & SD880 devices
* Tuned I/O scheduler and virtual memory parameters, especially on bluetooth earphones

# v2.4.9
* Improved "extras/jitter-reducer.sh" about thermal controls of performance Snapdragon's
* Optimized for POCO F3, but some of its custom ROM's cannot disable DRC (ArrowOS has inverted the DRC switch, so add "--drc" option to disable DRC)

# v2.4.8
* Tuned tunable values of the I/O jitter reducer and added "transition band cheat" option (specifying a cut-off point over the Nyquist frequency) to "extras/change-resampling-quality.sh"
* Fixed too many argument for resetprop

# v2.4.7
* Improved the I/O jitter-reducer

# v2.4.6
* Fixed a bug of usb-samplerate-unlocker detection
* Added AudioFlinger's current resampling quality print option to "extras/change-resampling-quality.sh"
* Improved "extras/change-resampling-quality.sh" for 1:1 ratio resampling, especially 44.1kHz 32bit data pass-through
* Tuned parameters of the I/O jitter reducer

# v2.4.5
* "extras/change-resampling-quality.sh" (a changer for the resampling quality of AudioFlinger (the OS mixer)) was added

# v2.4.4
* Enhanced the vm jitter reducer in /extras/jitter-reducer.sh to handle "swap_ratio" and "swap_ratio_enable" for Snapdradons
* Optimized tunables of the I/O jitter reducer
* Added LICENSE

# v2.4.3
* Improved "extras/jitter-reducer.sh" by fixing the GPU frequency at the max one for Qualcomm SoC (min_pwrlevel to the max level 0) and MTK SoC (fixed frequency at the max one with no governor) 

Remarks: Don't forget to disable "adaptive battery" in the battery section of "settings" and battery optimizations for "System UI" (system app), etc. to lower reverb like jitter distortion in digital audio outputs.

# v2.4.2
* Optimized the I/O jitter reducer in "extras/jitter-reducer.sh" for Snapdragon devices

# v2.4.1
* Added an "m-light" tone mode for the I/O jitter reducer to "extras'jitter-reduce.sh"

The mode is optimal for somewhat insensitive bluetooth earphones

# v2.4.0 (pre-release)
* Enhanced extras/jitter-reducer.sh by replacing the I/O jitter reducer with that of the hifi maximizer which uses "deadline" and "cfq" I/O schedulers and their optimized tunable values

# v2.3.0
* Enhanced extras/jitter-reducer.sh by adding a wifi jitter reducer which is especially effective for music streaming services (both online and offline), Pixel's and other high performance devices
* Cleaned up source codes

# v2.2.5
* Made "--io" option of "extras/jitter-reducer.sh" to have a parameter "nr_requests" (or presets "light", "medium" and "boost") for adjusting various peripheral devices (especially bluetooth earphones)

# v2.2.4
* "extras/jitter-reducer.sh" was improved for CPU&GPU governor and I/O scheduler (especially effective to bluetooth earphones)

# v2.2.3
* "extras/jitter-reducer.sh" was improved especially for old Qcomm devices

# v2.2.2 (pre-release)
* "extras/jitter-reducer.sh" was improved for virtual memory related jitters

# v2.2.1 (pre-release)
* "extras/jitter-reducer.sh" improved especially for old MTK SoC devices

# v2.2.0
* "extras/jitter-reducer.sh" (a simplified version of my ["Hifi Maximizer"](https://github.com/yzyhk904/hifi-maximizer-mod)) added

# v2.1.0
* ``--drc`` option added for the porpus of comparison to usual DRC-less audio quality

# v2.0.1
* "--safe", "--safest" and "--usb-only" options added

# v2.0.0 (pre-release)
* Supported "disable a2dp hardware-offload" in dev. settings and PHH treble GSI's "force disable a2dp hardware-offload"
* Set an r_submix HAL to be 44.1kHz 16bit mode
* Added "auto" mode for investigating device's environment and guessing best settings

# v1.3.2
* Over umounting and mount points loss issues was fixed

# v1.3.1
* Initial public release (on the Github)

# v1.3.0
* Selinux enforcing mode bug fixed

Now this script can be used under both selinux enforcing and permissive modes

# v1.2.0
* (USB) hardware offload support added (currently experimental)
* Bypass (USB) offload (using a non- USB hardware offload driver while the 3.5mm jack and internal speaker use a hardware offload driver) support added (currently experimental)

# v1.1.0
* Recent higher sample rates added

# v1.0.0
* Initial limited release

##
