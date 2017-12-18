/**
    Vector field simulation.
    Copyright (C) 2017  Valdemar Lindberg

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
#ifndef _VF_VEC_DEF_H_
#define _VF_VFC_DEF_H_ 1
#include<stdio.h>
#include<stdlib.h>
#include<limits.h>

/**
 *	Compiler version macro.
 */
#define VF_COMPILER_VERSION(major, minor, revision, state) VF_STR(major)VF_TEXT(".")VF_STR(minor)VF_TEXT(".")VF_STR(revision)

/**
 *    Compiler
 */
#ifdef _MSC_VER 	/*	Visual Studio C++ Compiler.	*/
	#define VF_VC
	#define VF_COMPILER 1
	#if _MSC_VER >= 1900
		#define VF_V13 _MSC_VER
	#elif _MSC_VER >= 1800
		#define VF_V12 _MSC_VER
	#elif _MSC_VER >= 1700
		#define VF_VC11 _MSC_VER
	#elif _MSC_VER >= 1600
		#define VF_VC10 _MSC_VER
	#elif _MSC_VER >= 1500
		#define VF_VC9 _MSC_VER
	#elif _MSC_VER >= 1400
		#define VF_VC8 _MSC_VER
	#elif _MSC_VER >= 1300
		#define VF_VC7 _MSC_VER
	#else
		#define VF_VC6 _MSC_VER
	#endif
    	#pragma warning(disable : 4201)
	#define VF_COMPILER_NAME "Visual Studio C++/C"

#elif defined(__clang__)  || defined(__llvm__)           /*  LLVM, clang   */
    #define VF_LLVM 1
	#define VF_CLANG 1
	#define VF_COMPILER 5
	#define VF_COMPILER_NAME "LLVM/CLANG"
	#define VF_COMPILER_MAJOR_VERSION __clang_major__
	#define VF_COMPILER_MINOR_VERSION __clang_minor__

#elif defined(__GNUC__) || defined(__SNC__) || defined( __GNUC_MINOR__)	/*  GNU C Compiler*/
	#define VF_GNUC 1
	#define VF_COMPILER 2
	#define VF_COMPILER_NAME "GNU C"
	#define VF_COMPILER_MAJOR_VERSION __clang_major__
	#define VF_COMPILER_MINOR_VERSION __clang_minor__

#elif defined(__GNUG__) /*  GNU C++ Compiler*/
	#define VF_GNUC 2

#elif defined(__ghs__)		/* GHS	*/
	#define VF_GHS 1
	#define VF_COMPILER 3

#elif defined(__HP_cc) || defined(__HP_aCC)			/*	*/

#elif defined(__PGI)			/*	*/

#elif defined(__ICC) || defined(__INTEL_COMPILER) /*  Intel Compiler  */
	#define VF_INTEL
	#define VF_COMPILER 4
	#define VF_COMPILER_NAME "Intel C++"

#elif defined(__SUNPRO_C) || defined(__SUNPRO_CC)

#else
	#error Unsupported Compiler.
#endif

/**
 *
 */
#if defined(__GNUC__) && defined(__ARM_NEON__)
     /* GCC-compatible compiler, targeting ARM with NEON */
     #include <arm_neon.h>
#endif	/**/

/**
 *	Platform define
 *	Architecture!
 */
#ifdef VF_VC
	#if defined(_M_IX86) || defined(_WIN32)
		#define VF_X86                          /**/
		#define VF_X32                          /**/
		#define VF_WIN32                        /**/
		#define VF_WINDOWS                      /**/
	#elif defined(_M_X64) || defined(_WIN64)
		#define VF_X64                          /**/
		#define VF_WIN64                        /**/
		#define VF_WINDOWS                      /**/
	#elif defined(_M_PPC)
		#define VF_PPC                          /**/
		#define VF_X360                         /**/
		#define VF_VMX                          /**/
	#elif defined(_M_ARM)
		#define VF_ARM                          /**/
		#define VF_ARM_NEON                     /**/
	#endif
#elif defined(VF_GNUC) || defined(VF_CLANG)
	#ifdef __CELLOS_LV2__   /**/
        #define VF_PS3                          /*	playstation 3*/
	#elif defined(__arm__)	/**/
		#define VF_ARM
        #define VF_PSP2                         /*	playstation portable 2*/
        #define VF_RAS_PI                       /*	rasberry pi	*/
	#endif
	#if defined(_WIN32) /**  Window*/
		#define VF_X86
		#define VF_WINDOWS                      /**/
	#endif
	#if ( defined(__linux__) || defined(__linux) || defined(linux) ) && (!(__ANDROID__) || !(ANDROID))/* Linux */
		#define VF_LINUX 1                       /**/
		#if defined(__amd64) || defined(__x86_64__) || defined(__i386__)
            #define VF_X86 1
			#define VF_X86_64 1
		#endif
		#if defined(__arm__)
              #define EX_ARM 1
        #endif

	#elif defined (ANDROID) || defined(__ANDROID__) || __ANDROID_API__ > 9  /** Android */
        #include<jni.h>
		#define VF_ANDROID 1
		/*  android Architecture*/
        #if defined(__arm__)
			#define VF_ARM 1
		  #if defined(__ARM_ARCH_7A__)
			#if defined(__ARM_NEON__)
			  #if defined(__ARM_PCS_VFP)
				#define ABI "armeabi-v7a/NEON (hard-float)"
			  #else
				#define ABI "armeabi-v7a/NEON"
			  #endif
			#else
			  #if defined(__ARM_PCS_VFP)
				#define ABI "armeabi-v7a (hard-float)"
			  #else
				#define ABI "armeabi-v7a"
			  #endif
			#endif
		  #else
		   #define ABI "armeabi"
		  #endif
		#elif defined(__i386__)
		   #define ABI "x86"
		#elif defined(__x86_64__)
		   #define ABI "x86_64"
		#elif defined(__mips64)  /* mips64el-* toolchain defines __mips__ too */
		   #define ABI "mips64"
		#elif defined(__mips__)
		   #define ABI "mips"
		#elif defined(__aarch64__)
		   #define ABI "arm64-v8a"
		#else
		   #define ABI "unknown"
		#endif

	#elif defined (__APPLE__)   /*  Apple product   */
		#define VF_APPLE 1
		#if defined(__arm__)
			#define VF_APPLE_IOS    /*  Apple iphone/ipad OS    */
		#elif defined(MACOSX) || defined(macintosh) || defined(Macintosh)
			#define EX_MAC 1
		#endif
	#elif defined(__CYGWIN) 	/**/
		#define VF_CYGWIN 1
		#define VF_LINUX 1
	#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__)   /*  BSD*/
		#define VF_BSD
    	#elif defined(__llvm__) || defined(__clang__)   	/*  llvm    */
        	#define VF_LLVM 1
	#endif

#elif defined(__ICC) || defined(__INTEL_COMPILER)


#else
	#error  Unsupported architecture!   /*  No architecture support implicitly. remove this line to compile anyway*/
#endif

#if defined(__native_client__)	/*	nacl google	*/
	#define VF_NACL 1
#endif
#if defined(__pnacl__)          /* portable nacl google */
	#define VF_PNACL 1
#endif
#if defined(__unix__) || defined(__unix) || defined(unix)	/*  Unix    */
	#   define VF_UNIX 1
#endif

/**
 *	Calling function convention.
 */
#ifdef VF_WINDOWS	        /** Windows Calling Convention.*/
	#define VFAPIENTRY     __cdecl
	#define VFAPIFASTENTRY __fastcall
	#define VFAPITHISENTRY __thiscall
	#define VFAPISTDENTRY  __stdcall
#elif defined(VF_ANDROID)   /** Android Calling Convention	*/
    #define VFAPIENTRY JNICALL
    #define VFAPIFASTENTRY JNICALL
    #define VFAPITHISENTRY JNICALL
    #define VFAPISTDENTRY JNICALL
#else
#   if !defined(__cdecl) && ( defined(VF_GNUC)  || defined(VF_CLANG) )
        #define __cdecl  __attribute__ ((__cdecl__))
        #define __stdcall  __attribute__ ((stdcall))
		#define __fastcall __attribute__((fastcall))
#   endif
	#define VFAPIENTRY     __cdecl
	#define VFAPISTDENTRY  __stdcall
	#define VFAPIFASTENTRY __fastcall
#endif

/**
 *	Force inline.
 */
#if defined(VF_MSVC)
	#define VF_ALWAYS_INLINE __forceinline
#elif defined(VF_GNUC)
	#define VF_ALWAYS_INLINE inline __attribute__((always_inline))
#elif defined(VF_GNUC) || defined(VF_GHS)
	#define VF_ALWAYS_INLINE inline __attribute__((always_inline))
#else
	/*#pragma message("Warning: You'd need to add VF_ALWAYS_INLINE for this compiler.")*/
#endif

/**
 *	Alignment of data and vectors.
 */
#if defined(VF_GNUC) || defined(VF_CLANG)
	#define VF_ALIGN(alignment) __attribute__ ((aligned(alignment)))
	#define VF_VECTORALIGN(alignment) __attribute__ ((__vector_size__ (alignment), __may_alias__))
	#define VF_VECTORALIGNI(alignment) __attribute__ ((__vector_size__ (alignment)))
#elif defined(VF_VC)
	#define VF_ALIGN(alignment) __attribute__ ((aligned(alignment)))
	#define VF_VECTORALIGN(alignment) __attribute__ ((__vector_size__ (alignment), __may_alias__))
	#define VF_VECTORALIGNI(alignment) __attribute__ ((__vector_size__ (alignment)))
#elif defined(VF_)
#endif

/**
 *	library declaration.
 */
#if defined(VF_GNUC) || defined(VF_CLANG)
	#if defined(VF_UNIX)
		#define VFDECLSPEC	 __attribute__((__visibility__ ("default")))
	#else
		#define VFDECLSPEC
	#endif
#elif defined(VF_VC)
	#if VF_INTERNAL
		#define VFDECLSPEC __declspec(dllexport)
	#else
		#define VFDECLSPEC __declspec(dllimport)
	#endif
#endif


#endif
