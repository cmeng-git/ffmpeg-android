# ffmpeg-android

* FFmpeg for Android with libvpx, x264 and lame options

## Supported android ABI's
* armeabi*
* armeabi-v7a
* arm64-v8a
* x86
* x86_64
* mips*
* mips64*

Note: *-Deprecated in android ndk-r16. Will be removed in ndk-r17.<br/>
see https://developer.android.com/ndk/guides/abis.html#Supported ABIs <br/>
ffmpeg-andorid releases > v1.5.0 will only verify ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")


## Instructions
* Set environment ANDROID_NDK variable; not all ndk releases work with all modules/ABIS
  - export ANDROID_NDK={Android NDK Base Path}<br/>
     e.g. export ANDROID_NDK=/opt/android/android-ndk-r17c (recommended);
* If necessary, fetch and update all libraries source (before build);
  - review and edit ./init_update_libs.sh file for your desired modules' versions
  - ./init_update_libs.sh
  - The default working sub-directories are ffmpeg, lame, libvpx, x264
  - For each sub-module, cd to the respective directory and execute ./configure without option;<br/>
     The configure process may list any missing sdk build tools, please install before continue
  - The final configure with options for each submodule is done in each submodule _\<module>_build.sh build script 
* Edit ./ffmpeg-android_build.sh [#1] and ./_settings.sh [#2];<br/>
  a. remove any of the codec sub-modules or architectures you wish to be excluded from the build<br/>
  b. add "ffmpeg" to [#1] if you want to build standalone ffmpeg without inclusion of the sub-modules integration<br/>
  c. the default values are defined as:
  - MODULES=("vpx" "x264" "lame") [#1]
  - ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64") [#2]
* To support 64-bit libraries built, ensure _settings.sh#ANDROID_API=21 (min API for 64-bit library build).<br/>
  Note: application.mk in Android Studio i.e. APP_PLATFORM := android-21 i.e. both must use the same API
* Enter either one of the following commands to compile ffmpeg for all or one the supported ABI's etc
  - ./ffmpeg-android_build.sh [#1]
  - ./ffmpeg-android_build.sh armeabi-v7a (i.e. selected cpu with all predefined codec modules)
  - ./ffmpeg-android_build.sh armeabi-v7a x264 (i.e. selected cpu with only x264 codec module)
* All the generated static libraries and includes files are installed in ./jni/\<MODULE>/android/\<ABI>.

## Linking with versioned shared library in Android NDK
* Note: the latest _vpx_build.sh has included the scripts to patch the following automatically. Manual change is not further required.<br/><br/>
* Android has an issue with loading versioned .so shared libraries e.g. x264:
* Causing error during run: java.lang.UnsatisfiedLinkError: dlopen failed: library "libx264.so.147" not found
* Perform the following patches, if you want to link with shared .so libraries for x264.
  1. use GHex to change file content "libx264.so.147" to "libx264_147.so"
  2. change filename from libx264.so.147 to libx264_147.so
  3. Note: the .so filename must match with the file changed content


## Verification Status
* The scripts has been verified working with the following configurations:
  - ABIS: armeabi-v7a, arm64-v8a, x86, x86_64
  - MODULES (with applied patches): ffmpeg-v4.1.1, libvpx-v1.8.0, x264-v157, lame-v3.100  
  - NDK version: ndk-r17c (build failed with lower or higher versions - see below)
  - ANDROID_API: 21

* x264 (v157 and v152):
  - x264 option: --disable-asm<br/>
    Must exclude the option for arm64. Used by configure, config.mak and Makefile to define AS and to compile required *.S assembly files.<br/>
    Otherwise will have undefined references e.g. x264_8_... x264_10...<br/>
    However must include the option for x86 and x86_64; otherwise have relocate text, requires dynamic R_X86_64_PC32 etc when use in aTalk
  - ndk-r18b, ndk-r17c, ndk-16b, ndk-r15c (build all)

* libvpx (v.1.8.0):
  - libvpx configure.sh needs patches to correctly build the arm64 with SDK toolchains. 
  - When --sdk-path is specified, libvpx configure uses SDK toolchains compiler (gcc/g++);
    * ndk-r17c, ndk-r16b:<br/>
      To avoid missing stdlib.h and other errors, need to include the following two options for SDK toolchains:<br/>
      --extra-cflags="-isystem ${NDK}/sysroot/usr/include/${NDK_ABIARCH} -isystem ${NDK}/sysroot/usr/include"<br/>
      --libc=${NDK_SYSROOT} => use standalone toolchains directory. libvpx configure.sh has problem configure this with SDK properly
    * ndk-r18b: gcc option has been removed<br/>
     build failed with: /home/cmeng/workspace/ndk/ffmpeg-android/toolchain-android/bin/aarch64-linux-android-ld: cannot find -lgcc
  - When using standalone toolchains, i.e. (omit --sdk-path);
    * ndk-r18b, ndk-r17c, ndk-r16b: <br/>
    Build ok with ABIS=("arm64-v8a" "x86" "x86_64") but not "armeabi-v7a" and failed with:<br/>
    /tmp/vpx-conf-4350-25363.o(.ARM.exidx.text.main+0x0): error: undefined reference to '__aeabi_unwind_cpp_pr0' 

* lame (v3.1000):
  - ndk-r17b - build all and can integrate with ffmpeg
  - ndk-r16b, ndk-r15c (build all)
  - ndk-r18b - failed
  - PREFIX must use absolution path

* ffmpeg (v4.1.1):
  - Must include option --disable-asm for x86, otherwise <br/>
    libavcodec/x86/cabac.h:193:9: error: inline assembly requires more registers than available<br/>
    ffmpeg (v1.0.10) => must also include this option for arm/arm64 build, otherwise errors during compilation 
  - ndk-r18b, ndk-r17c => give error on: (fixed by patch)<br/>
    libavdevice/v4l2.c:135:9: error: assigning to 'int (*)(int, unsigned long, ...)' from incompatible type '<overloaded function type>'
        SET_WRAPPERS();
  - ndk-r16b or lower => gives error on:<br/>
    libavformat/udp.c:290:28: error: member reference base type '__be32' (aka 'unsigned int') is not a structure or union<br/>
        mreqs.imr_multiaddr.s_addr = ((struct sockaddr_in *)addr)->sin_addr.s_addr;
  
* Note:
  - NDK verification status (build with clang/clang++ and API-21 unless otherwise specified):
  - Recommendation: use ndk-r17c and API-21 unless you have other considerations.
  - clang support needs min ndk-r12c, but may not necessary works for all ABIS (64-bit built has problem)
  - Change _settings.sh with clang=>gcc and clang++=>g++ if you need lower ndk version
  - NDK >r18b has obsoleted the support for the gcc/g++

## Help:
* Set up Linux/Ubuntu development environment with the below build tools
  - sudo apt-get --quiet --yes install build-essential git autoconf libtool pkg-config gperf gettext yasm python-lxml
* Patches for Sub-module
  - ./ffmpeg-android_build.sh includes the patches for the sub-modules 
  - ffmpeg-android_patch.sh applies patches to the relevant sub-module with patch files from ./pathes directory
  - edit these files to include additional patches if required.
* Configuration failed
  - You may encounter this problem during the codec sub-module build, navigate to the respective sub-module directory:
    - Issue the command line i.e. configure --help to check for the available options 
    - Refer to config.log of the sub-module for more info.
    - Refer to the configure file for more information on CPU types supported
    - Edit the script file to make the necessary modifications based on help and errors found in config.log
* During sub-module built, you may encountered compilation or linker errors, changing ndk version may help resolve the issues.<br/>
  However it may create new problems in another areas.
  
* Utilize Modern Compiler Flags to Address Potential Security Issues
  - Stack execution protection:                    LDFLAGS="-z noexecstack" 
  - Data relocation and protection (RELRO):        LDLFAGS="-z relro -z now" 
  - Stack-based Buffer Overrun Detection:          CFLAGS=”-fstack-protector-strong”
                                                   if using GCC 4.9 or newer, otherwise CFLAGS="-fstack-protector"
  - Position Independent Execution (PIE)           CFLAGS="-fPIE -fPIC" LDFLAGS="-pie" (PIE for executables only)
  - Fortify source:                                CFLAGS="-O2 -D_FORTIFY_SOURCE=2"
  - Format string vulnerabilities:                 CFLAGS="-Wformat -Wformat-security"
   
## Note:
* The scripts in this folder are not compatible with Unified Headers:<br/>
See https://android.googlesource.com/platform/ndk/+/master/docs/UnifiedHeaders.md#supporting-unified-headers-in-your-build-system

* Both the android NDK, ffmpeg and its sub-modules are in continous update, it is likely that <br/>
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
* https://github.com/nodejs/node/issues/18671 (Utilize Modern Compiler Flags to Address Potential Security Issues #18671)
* https://android.googlesource.com/platform/external/libvpx/+/ca30a60d2d6fbab4ac07c63bfbf7bbbd1fe6a583 (Add visibility="protected" attribute for global variables referenced in asm files.)


## License

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


