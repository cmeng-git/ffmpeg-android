# ffmpeg-android

* FFmpeg for Android with x264 and lame options

Supported android ABI's
----
* armeabi
* armeabi-v7a
* arm64-v8a
* mips
* mips64
* x86
* x86_64

Instructions
----
* Set environment ANDROID_NDK variable e.g. /opt/android/android-ndk-r16b
  1. export ANDROID_NDK={Android NDK Base Path}
* NDK verification status (build with clang/clang++ and API-21 unless otherwise specified):
  1. x264: android-sdk/ndk-bundle, android-ndk-r16b, android-ndk-r15c, android-ndk-r10e (build all)
  2. lame-3.100: android-ndk-r16b (build all)
  3. ffmpeg android-ndk-r16b (build all except arm64-v8a and mips64)
  4. clang needs android-ndk-r15c min for support. Change setttins.sh with clang=>gcc and clang++=>g++ if you need lower ndk version
* To fetch and update submodules and libraries; use ./init_update_libs.sh command
  1. ./init_update_libs.sh
  2. edit the ./init_update_libs.sh files for your desired module version
* Run either one of the following commands to compile ffmpeg for all or one the supported ABI's
  1. ./ffmpeg-android_build.sh
  2. ./ffmpeg-android_build.sh armeabi-v7a (example)
  3. As #1 but create custom settings.sh#ABIS=("armeabi" "armeabi-v7a" "arm64-v8a" "mips" "mips64" "x86" "x86_64") for your project
* To support 64bit libraries built, change settings.sh#ANDROID_API=21; min API for 64-bit library build.
* All the generated static libraries and includes are in ./build/ffmpeg/android/<ABI> directory.

Help:
-------
* Set up Linux/Ubuntu development environment with the below build tools
  1. sudo apt-get --quiet --yes install build-essential git autoconf libtool pkg-config gperf gettext yasm python-lxml

* Patches for Sub-module
  1. ./ffmpeg-android_build.sh includes the patches for the sub-modules 
  2. ffmpeg-android_patch.sh applies patches to the relevant sub-module with patch files from ./pathes directory
  3. edit these files to include additional patch if required.

* see https://developer.android.com/ndk/guides/abis.html#Supported ABIs
* Android recommended ABI's support; others have deprecated in r16 and will be removed in r17
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

Note:
-------
Both the android NDK, ffmpeg and its sub-modules are in continous update, it is likely that
some of the defined ABI's settings may need to be tweaked as submodule configure have new changes.

Please refer to the following sites which may offer solution for problems you may experience.
* https://ffmpeg.org/pipermail/ffmpeg-user/2016-January/030202.html
* https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg62644.html
* http://alientechlab.com/how-to-build-ffmpeg-for-android/
* https://en.wikipedia.org/wiki/List_of_ARM_microarchitectures


License
-------

    ffmpeg, android static library for aTalk VoIP and Instant Messaging client
    
    Copyright 2014 Eng Chong Meng
        
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
       http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


[Privacy Policy](http://atalk.sytes.net/privacypolicy.html) 

