# ffmpeg-android
==============

* FFmpeg for Android with x264 and lame options

Supported Architecture
----
* armeabi
* armeabi-v7a
* arm64-v8a
* x86
* x86_64
* mips
* mips64

Instructions
----
* Set environment ANDROID_NDK variable e.g. /opt/android/android-ndk-r10e
  1. export ANDROID_NDK={Android NDK Base Path}
* NDK verification status:
  1. x264: android-ndk-r10e; android-ndk-r15c; android-sdk/ndk-bundle for API-21 with 64-bit build
  2. lame (3.99.5): android-ndk-r10e for API-15 without 64-bit build
  3. ffmpeg android-android-ndk-r10e (API-15: without 64-bit build; other NDK have undefined reference stderr, stdout etc even with API-21)
  4. android-ndk-r10e does not support clang, however android-ndk-r15c does
* Install all the build tools if missing
  1. sudo apt-get --quiet --yes install build-essential git autoconf libtool pkg-config gperf gettext yasm python-lxml
* To fetch and update submodules and libraries; use ./init_update_libs.sh command
  1. ./init_update_libs.sh
* Run either one of the following commands to compile ffmpeg for all, custom or one the supported architecture
  1. ./ffmpeg-android_build.sh
  2. As #1 but create custom setting.sh#ARCHS=("armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mips" "mips64") for your project
  3. ./ffmpeg-android_build.sh armeabi-v7a
* To support 64bit libraries built, change setting.sh#ANDROID_API=21; min API for 64-bit library build.
* All the generated static libraries and includes are in ./build directory.
* Note: Some of the defined architecture settings may need to tweak as each module library configure options may change over time.

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

