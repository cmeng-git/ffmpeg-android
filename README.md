# ffmpeg-android

* FFmpeg for Android with x264 and lame options

Supported android ABI's
-------
* armeabi*
* armeabi-v7a
* arm64-v8a
* x86
* x86_64
* mips*
* mips64*

Note: *-Deprecated in android NDK r16. Will be removed in r17
see https://developer.android.com/ndk/guides/abis.html#Supported ABIs

Instructions
-------
* Set environment ANDROID_NDK variable e.g. /opt/android/android-ndk-r16b
  1. export ANDROID_NDK={Android NDK Base Path}
* To fetch and update submodules and libraries if necessary (before build); use ./init_update_libs.sh command
  1. ./init_update_libs.sh
  2. edit the ./init_update_libs.sh files for your desired module version
* To support 64-bit libraries built, change settings.sh#ANDROID_API=21 (min API for 64-bit library build).
  Also application.mk in AS i.e. APP_PLATFORM := android-21 i.e. both must use the same API
* Enter either one of the following commands to compile ffmpeg for all or one the supported ABI's etc
  1. ./ffmpeg-android_build.sh
  2. ./ffmpeg-android_build.sh armeabi-v7a (i.e. selected cpu with all predefined codec modules)
  3. ./ffmpeg-android_build.sh armeabi-v7a x264 (i.e. selected cpu with only x264 codec module)
  4. As #1 but create custom settings.sh#ABIS=("armeabi" "armeabi-v7a" "arm64-v8a" "mips" "mips64" "x86" "x86_64") for your project
* All the generated static libraries and includes files are in ./android/<ABI> directory.

Linking with versioned shared library in Android NDK
-------
* Android has an issue with loading versioned .so libraries e.g. x264:
* Causing error during run: java.lang.UnsatisfiedLinkError: dlopen failed: library "libx264.so.147" not found
* Perform the following patches, if you want to link with shared .so libraries for x264.
1. use GHex to change file content "libx264.so.147" to "libx264_147.so"
2. change filename from libx264.so.147 to libx264_147.so
3. Note: the .so filename must match with the file changed content

Verification Status
-------
* NDK verification status (build with clang/clang++ and API-21 unless otherwise specified):
  1. x264: ndk-r16b, ndk-r15c (build all; except arm64-v8a libx.a has own undefined references e.g. x264_8_... x264_10...)
  2. libvpx-1.7.0: ndk-r15c (build all except mips and mips64; ndk-r16b built has errors - see vpx_build.sh);
  configure with Target=arm64-android-gcc has error which uses incorrect cc i.e. arm-linux-androideabi-gcc;
  3. lame-3.100: ndk-r16b, ndk-r15c (build all)
  4. ffmpeg ndk-r16b, ndk-r15c (build all - but failed when include x264 for arm64-v8a architecture)
  5. clang support needs min ndk-r12c, but may not neccessary works for all ABIS (64-bit built has problem)
  6. Change settings.sh with clang=>gcc and clang++=>g++ if you need lower ndk version
* Recommendation: use ndk-r15c and API-21 unless you have other considerations.

Help:
-------
* Set up Linux/Ubuntu development environment with the below build tools
  1. sudo apt-get --quiet --yes install build-essential git autoconf libtool pkg-config gperf gettext yasm python-lxml

* Patches for Sub-module
  1. ./ffmpeg-android_build.sh includes the patches for the sub-modules 
  2. ffmpeg-android_patch.sh applies patches to the relevant sub-module with patch files from ./pathes directory
  3. edit these files to include additional patches if required.

Note:
-------
* x264.a generated for arm64-v8a has undefined references to its own *.o files e.g. x264_8_... x264_10... when linking
with ffmpeg. It seems to be an x264 configure file problem.

* The scripts in this folder are not compatible with Unified Headers:
See https://android.googlesource.com/platform/ndk/+/master/docs/UnifiedHeaders.md#supporting-unified-headers-in-your-build-system

* Both the android NDK, ffmpeg and its sub-modules are in continous update, it is likely that
some of the defined ABI's settings may need to be tweaked as submodule configure have new changes.

Please refer to the following sites which may offer solution for problems you may experience.
* https://ffmpeg.org/pipermail/ffmpeg-user/2016-January/030202.html
* https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg62644.html
* http://alientechlab.com/how-to-build-ffmpeg-for-android/
* https://en.wikipedia.org/wiki/List_of_ARM_microarchitectures
* https://github.com/google/ExoPlayer/issues/3520 (VP9 builds failure with android-ndk-r16 #3520)
* https://github.com/android-ndk/ndk/issues/190#issuecomment-375164450 (unknown type name __uint128_t on ndk-build #190)
* https://android.googlesource.com/platform/bionic/+/master/docs/32-bit-abi.md
* https://github.com/android-ndk/ndk/issues/477 (mmap causes compile errors on r15c (unknown identifier) #477)
* https://github.com/android-ndk/ndk/issues/503 (implicit declaration of function 'mmap' #503)

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


