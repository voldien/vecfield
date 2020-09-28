cmake_minimum_required(VERSION 3.7.2)
PROJECT(vecfield)
OPTION(BUILD_WITH_EXTERNAL_PROJECT "Build with external" ON)

# Set version of the project.
SET(VERSION_MAJOR 0)
SET(VERSION_MINOR 9)
SET(VERSION_REVISION 0)
SET(VERSION_STATE b)
SET(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}${VERSION_STATE}${VERSION_REVISION} )
SET(PROJECT_VERSION "${VERSION}")

# Set predefined macro for version.
ADD_DEFINITIONS(-DVF_STR_VERSION="${VERSION}")
ADD_DEFINITIONS(-DCL_TARGET_OPENCL_VERSION=220)

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
ELSE()
	MESSAGE(FATAL_ERROR "Non supported compiler!")
ENDIF()

FIND_PACKAGE(Git)
IF(GIT_FOUND)
	MESSAGE(STATUS "git found: ${GIT_EXECUTABLE} -- ${GIT_VERSION_STRING}")
ENDIF()
IF(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
	# Update submodules as needed
	OPTION(GIT_SUBMODULE "Check submodules during build" ON)
	IF(GIT_SUBMODULE)
		MESSAGE(STATUS "Submodule update")
		EXECUTE_PROCESS(COMMAND ${GIT_EXECUTABLE} submodule update --init
						WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
						RESULT_VARIABLE GIT_SUBMOD_RESULT)
		IF(NOT GIT_SUBMOD_RESULT EQUAL "0")
			MESSAGE(FATAL_ERROR "git submodule update --init failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
		ENDIF()
	ENDIF()
ELSE()

ENDIF()

IF (BUILD_WITH_EXTERNAL_PROJECT)
	INCLUDE(ExternalProject)
	IF (NOT GIT_FOUND)
		MESSAGE(FATAL_ERROR "Git is required in order to fetch the external project hpm.")
	ENDIF ()

	SET_PROPERTY(DIRECTORY PROPERTY EP_STEP_TARGETS build)

	# Download the hpm library.
	SET(HPM_ROOT ${CMAKE_CURRENT_BINARY_DIR}/deps/hpm)
	SET(HPM_LIB_DIR ${HPM_ROOT}/lib)
	SET(HPM_INCLUDE_DIR ${HPM_ROOT}/include)
	ExternalProject_Add(hpm-external
			URL ${CMAKE_CURRENT_SOURCE_DIR}/extern/hpm
			SOURCE_DIR ${HPM_ROOT}/src/hpm
			BINARY_DIR ${HPM_ROOT}/src/hpm-build
			INSTALL_DIR ${HPM_ROOT}
			CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_TEST=OFF
			STEP_TARGETS build
			COMMENT "Building Hpm."
			LOG_DOWNLOAD ON)
	# Include HPM headers.
	ADD_LIBRARY(hpm SHARED IMPORTED)
	ADD_DEPENDENCIES(hpm hpm-external)
	SET_TARGET_PROPERTIES(hpm PROPERTIES
			IMPORTED_LOCATION ${HPM_LIB_DIR}/libhpm.so
			INTERFACE_LINK_LIBRARIES ${HPM_LIB_DIR}/libhpm.so
				INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/extern/hpm/include)
	SET(HPM_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/extern/hpm/include")
ENDIF ()

# Find OpenGL and OpenCL information.
SET(OpenGL_GL_PREFERENCE "GLVND")
FIND_PACKAGE(OpenGL REQUIRED)
FIND_PACKAGE(OpenCL REQUIRED)
INCLUDE_DIRECTORIES(${OPENCL_INCLUDE_DIR})

# Define all file lists.
FILE(GLOB SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.m)
FILE(GLOB SHADER_GL_FILES ${CMAKE_CURRENT_SOURCE_DIR}/shader/)
FILE(GLOB SHADER_CL_FILES ${CMAKE_CURRENT_SOURCE_DIR}/cl/)

# Define main target.
ADD_EXECUTABLE(vecfield ${SOURCE_FILES})
ADD_DEPENDENCIES(vecfield shaders hpm)
TARGET_INCLUDE_DIRECTORIES(vecfield PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include ${HPM_INCLUDE_DIRS}  PUBLIC )

TARGET_LINK_LIBRARIES(vecfield gnustep-base OpenCL objc GL GLEW SDL2 freeimage z zip hpm m)
INSTALL(TARGETS vecfield DESTINATION bin)

# Only UNIX systems.
IF( UNIX )

	# Create default shader zip file.
	SET( SHADERZIP "vfcommon" )
	SET( SHADERZIPFILE "${SHADERZIP}.zip" )
	ADD_CUSTOM_TARGET(	shaders
				DEPENDS	${SHADER_GL_FILES}
					${SHADER_CL_FILES}
				COMMAND mkdir -p share
				COMMAND cp -r ${CMAKE_CURRENT_SOURCE_DIR}/shader/* share/
		                COMMAND cp -r ${CMAKE_CURRENT_SOURCE_DIR}/cl/* share/
				COMMAND zip -r ${SHADERZIPFILE} share/
				COMMAND rm -r share
				COMMENT "Generate common file required.")
	INSTALL( FILES ${SHADERZIPFILE} DESTINATION /usr/share/vecfield )
	INSTALL( FILES vecfield.bc DESTINATION /usr/share/bash-completion/completions RENAME vecfield)

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


