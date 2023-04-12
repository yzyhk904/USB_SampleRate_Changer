## Change logs

# v2.6
* Added support for the usbv2 HAL module

# v2.5
* Added extras/change-resampling-quality.sh (to reduce resampling distortion) and extras/change-usb-period.sh (to reduce the jitter of a PLL in a DAC)directly). Tuned kernel tunables by assuming an audio scheduling tunable "vendor.audio.adm.buffering.ms" to be "2" (please set this property by my magisk modules ["usb-samplerate-unlocker"](https://github.com/Magisk-Modules-Alt-Repo/usb-samplerate-unlocker) and/or ["audio-misc-settings"](https://github.com/Magisk-Modules-Alt-Repo/audio-misc-settings)).

# v2.4
* Enhanced extras/jitter-reducer.sh by replacing the I/O jitter reducer with that of the hifi maximizer which uses "deadline" and "cfq" I/O schedulers and their optimized tunable values

# v2.3
* Enhanced extras/jitter-reducer.sh by adding a wifi jitter reducer which is especially effective for music streaming services (both online and offline), Pixel's and other high performance devices
* Cleaned up source codes

# v2.2
* extras/jitter-reducer.sh (a simplified version of my ["Hifi Maximizer"](https://github.com/yzyhk904/hifi-maximizer-mod)) added

# v2.1
* ``--drc`` option added for the porpus of comparison to usual DRC-less audio quality

# v2.0
* Supported "disable a2dp hardware-offload" in dev. settings and PHH treble GSI's "force disable a2dp hardware-offload"
* Set an r_submix HAL to be 44.1kHz 16bit mode
* Added "auto" mode for investigating device's environment and guessing best settings

# v1.3
* Selinux enforcing mode bug fixed. Now this script can be used under both selinux enforcing and permissive modes

# v1.2
* (USB) hardware offload support added (currently experimental)
* Bypass (USB) offload (using a non- USB hardware offload driver while the 3.5mm jack and internal speaker use a hardware offload driver) support added (currently experimental)

# v1.1
* Recent higher sample rates added

# v1.0
* Initial Release

##
