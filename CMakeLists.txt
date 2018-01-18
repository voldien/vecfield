cmake_minimum_required(VERSION 3.7.2)
PROJECT(vecfield)

# Set version of the project.
SET(VERSION_MAJOR 0)
SET(VERSION_MINOR 9)
SET(VERSION_REVISION 0)
SET(VERSION_STATE a)
SET(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}${VERSION_STATE}${VERSION_REVISION} )
SET(PROJECT_VERSION "${VERSION}")

# Set predefined macro for version.
ADD_DEFINITIONS(-DVF_STR_VERSION="${VERSION}")

# gcc compiler flags
SET(CMAKE_CXX_STANDARD 11)
IF((CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX) AND NOT CMAKE_COMPILER_IS_MINGW)

    # Set compile flag for enabling objective c support.
    ADD_DEFINITIONS(-MMD -MP -Wdate-time -D_FORTIFY_SOURCE=2 -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -fdebug-prefix-map=/build/gnustep-make-hGI6_J/gnustep-make-2.6.8=. -specs=/usr/share/dpkg/no-pie-compile.specs -fstack-protector-strong -Wformat -Werror=format-security -fdebug-prefix-map=/build/gnustep-make-hGI6_J/gnustep-make-2.6.8=. -specs=/usr/share/dpkg/no-pie-compile.specs -fstack-protector-strong -Wformat -Werror=format-security -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/home/voldie/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep)
    ADD_DEFINITIONS(-I/usr/include/GNUstep)

	IF (CMAKE_BUILD_TYPE STREQUAL "Release")
		MESSAGE(STATUS "Compile for release.")
		ADD_DEFINITIONS( -DNDEBUG )
		ADD_DEFINITIONS( -O2 -s)
		SET(CMAKE_RELEASE TRUE)
	ELSE()
		MESSAGE(STATUS "Compile for debug.")
		ADD_DEFINITIONS( -D_DEBUG )
		ADD_DEFINITIONS( -g3 -O0 )
		SET(CMAKE_DEBUG TRUE)
	ENDIF()
ELSEIF(MSVC)

	# Enable multi-core complication with MSVC
	ADD_DEFINITIONS(/MP)
endif()

#
INCLUDE_DIRECTORIES({CMAKE_CURRENT_SOURCE_DIR}/include)
ADD_DEFINITIONS(-I${CMAKE_CURRENT_SOURCE_DIR}/include)

# Find OpenGL and OpenCL information.
FIND_PACKAGE(OpenGL REQUIRED)
FIND_PACKAGE(OpenCL REQUIRED)
INCLUDE_DIRECTORIES(${OPENCL_INCLUDE_DIR})

# Define all file lists.
FILE(GLOB SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.m)
FILE(GLOB SHADER_GL_FILES ${CMAKE_CURRENT_SOURCE_DIR}/shader)
FILE(GLOB SHADER_CL_FILES ${CMAKE_CURRENT_SOURCE_DIR}/cl)

# Define main target.
ADD_EXECUTABLE(vecfield ${SOURCE_FILES})
ADD_DEPENDENCIES(vecfield shaders)

TARGET_LINK_LIBRARIES(vecfield -lgnustep-base -lOpenCL -lobjc -lGL -lGLEW -lSDL2 -lfreeimage -lz -lzip -lhpm -lm)
INSTALL(TARGETS vecfield DESTINATION bin)

# Only UNIX systems.
IF( UNIX )

	# Create default shader zip file.
	SET( SHADERZIP "vfcommon" )
	SET( SHADERZIPFILE "${SHADERZIP}.zip" )
	ADD_CUSTOM_TARGET(	shaders
				COMMAND mkdir -p share
				COMMAND cp -r shader/* share/
		                COMMAND cp -r cl/* share/
				COMMAND zip -r ${SHADERZIPFILE} share/
				COMMAND rm -r share)
	INSTALL( FILES ${SHADERZIPFILE} DESTINATION /usr/share/vecfield )

	# Create distribution tarball.
	SET( TARGETDIR "${PROJECT_NAME}-${VERSION}")
	ADD_CUSTOM_TARGET(	distribution
				COMMAND mkdir -p ${TARGETDIR}
				COMMAND cp -r src include shader cl CMakeLists.txt LICENSE ${TARGETDIR}
				COMMAND tar cf - ${TARGETDIR} | gzip -c > ${TARGETDIR}.tar.gz 
				COMMAND rm -r ${TARGETDIR} )
ELSEIF(WIN32)

ELSE()

ENDIF()


