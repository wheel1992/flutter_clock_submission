# Digital Clock

This digital clock app is built on top of existing `digital_clock` sample.

## Test Device

Tested on Android Emulator with the following specification.

|Name|Specification|
|:--|:--|
|Screen Size|`4"` (Similar to Lenovo Smart Clock)|
|Resolution|`480 x 800` (Similar to Lenovo Smart Clock)|
|Android| `API 28`|
|Orientation|`Landscape`|
|RAM|`1024 MB`|
|Internal Storage|`800 MB`|
|VM Heap|`48 MB`|

## Test Web

After submitting the project, I have tried my first Flutter web with Firebase hosting.
Sample of [clock in web](wheel1992/flutter_clock_submission)

## Features

### **Color & Wave Changes**

The color gradient change with respect to the current hour.

The wave height change with respect to the current hour.

|Time Period|Light|Dark|Wave Height|
|:--|:-:|:-:|:--|
|Morning|![](screenshots/light_morning.png)|![](screenshots/dark_morning.png)|Approx. 0.3 of screen height|
|Afteroon|![](screenshots/light_afternoon.png)|![](screenshots/dark_afternoon.png)|Approx. 0.5 of screen height|
|Evening|![](screenshots/light_evening.png)|![](screenshots/dark_evening.png)|Approx. 0.79 of screen height|
|Midnight|![](screenshots/light_midnight.png)|![](screenshots/dark_midnight.png)|Approx. 0.04 of screen height|

### Time format

|Format|Example|
|:--|:-:|
|12 Hours|![](screenshots/format_12_hrs.png)|
|24 Hours|![](screenshots/format_24_hrs.png)|

### **Weather Icon**

Icons are from [Joseph Cheng - Weather Flat Icons](https://rive.app/a/josephcheng/files/flare/weather-flat-icons/preview) which is a edited version and forked from [AmirHossein SamadiPour - Weather Flat Icons](https://rive.app/a/SamadiPour/files/flare/weather-flat-icons/preview). Under [License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)