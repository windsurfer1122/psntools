## https://cmake.org/cmake/help/latest/index.html
CMAKE_MINIMUM_REQUIRED(VERSION 3.14)
## 3.8: SWIG_ADD_LIBRARY()
## 3.12: ~SWIG_FLAGS, +FindPython, -FindPythonLibs
## 3.13: TARGET_SOURCES() relative
## 3.14: property SWIG_MODULE_NAME

## Log some properties for project
MESSAGE(VERBOSE "SWIG Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
MESSAGE(VERBOSE "++ SWIG PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}")
MESSAGE(VERBOSE "++ SWIG PROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}")


## Include package SWIG
CMAKE_POLICY(SET CMP0078 NEW) ## 3.13+
CMAKE_POLICY(SET CMP0086 NEW) ## 3.14+
FIND_PACKAGE(SWIG REQUIRED COMPONENTS python)
INCLUDE(${SWIG_USE_FILE})

## Define SWIG environment
SET(SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON)

## Define source properties
SET_SOURCE_FILES_PROPERTIES("swig/${PROJECT_NAME}.i"
	PROPERTIES
		SWIG_MODULE_NAME "${PROJECT_NAME}"
		SWIG_FLAGS "-includeall"
)


## Define macros for SWIG builds for Python
MACRO(do_raprif_python_swig py_build_version py_dev_version py_dev_include_dir)
	## >>>>> Define Python environment
	SET(PYTHON_TARGET_NAME_BASE "${PROJECT_NAME}_python${py_build_version}_swig")
	SET(PYTHON_OUTPUT_DIR "target-python${py_build_version}-swig")
	SET(PYTHON_OUTPUT_PATH "${CMAKE_BINARY_DIR}/${PYTHON_OUTPUT_DIR}")
	MESSAGE(VERBOSE "++ PYTHON_OUTPUT_PATH=${PYTHON_OUTPUT_PATH}")
	SET(PYTHON_REQUIRED ">=2.7")


	## >>>>> Define TARGET for SWIG BDIST Python extension module
	SET(PYTHON_TARGET_TYPE "bdist")
	## Define source files (explicitly!) for SDIST Python extension module
	SWIG_ADD_LIBRARY("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		TYPE MODULE
		LANGUAGE python
		OUTPUT_DIR "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
		OUTFILE_DIR "${PYTHON_OUTPUT_PATH}/sdist/src"
		SOURCES "swig/${PROJECT_NAME}.i"
	)

	## Define target dependencies for SWIG BDIST Python extension module
	ADD_DEPENDENCIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		"${CMAKE_PROJECT_NAME}_python${py_build_version}_swig_${PYTHON_TARGET_TYPE}"
	)

	## Define properties for SWIG BDIST Python extension module
	SET_TARGET_PROPERTIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PROPERTIES
			BUILD_WITH_INSTALL_RPATH TRUE
			LIBRARY_OUTPUT_NAME "${PROJECT_NAME}"
			LIBRARY_OUTPUT_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
			ARCHIVE_OUTPUT_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
			WINDOWS_EXPORT_ALL_SYMBOLS YES CACHE BOOL
	)

	## Define source files (explicitly!) for SWIG BDIST Python extension module
	TARGET_SOURCES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRIVATE
			"swig/${PROJECT_NAME}.i"
	)

	## Define library dependencies for SWIG BDIST Python extension module
	TARGET_LINK_LIBRARIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRIVATE
			"${PROJECT_NAME}"
	)

	## Define include directories for SWIG BDIST Python extension module
	TARGET_INCLUDE_DIRECTORIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRIVATE
			${py_dev_include_dir}
	)

	## Log some properties for SWIG BDIST Python extension module
	GET_TARGET_PROPERTY(RAPRIF_INCDIRS "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}" INCLUDE_DIRECTORIES)
	GET_TARGET_PROPERTY(RAPRIF_SRCS "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}" SOURCES)
	#
	MESSAGE(VERBOSE "++ SWIG INCLUDE_DIRECTORIES=${RAPRIF_INCDIRS}")
	MESSAGE(VERBOSE "++ SWIG SOURCES=${RAPRIF_SRCS}")


	## >>>>> Define TARGET for SWIG SDIST Python extension module
	SET(PYTHON_TARGET_TYPE "sdist")
	## Define source files (explicitly!) for SDIST Python extension module
	ADD_CUSTOM_TARGET("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		ALL
		DEPENDS
			"include/raprif.h"
			"src/raprif.c"
	)

	## Define target dependencies for SWIG SDIST Python extension module
	ADD_DEPENDENCIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		"${PYTHON_TARGET_NAME_BASE}_bdist"
		"${CMAKE_PROJECT_NAME}_python${py_build_version}_swig_${PYTHON_TARGET_TYPE}"
	)

	## Define copy commands for SDIST Python extension module
	copy_raprif_python_sdist("${py_build_version}" "SWIG ")

	## Define copy command for Python sources for SWIG SDIST Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} SWIG generated Python sources to Python ${py_build_version} ${CMAKE_PROJECT_NAME} SWIG ${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
		COMMAND "${CMAKE_COMMAND}" -E copy "${PYTHON_OUTPUT_PATH}/bdist/${CMAKE_PROJECT_NAME}/${PROJECT_NAME}.py" "."
	)
ENDMACRO(do_raprif_python_swig)


## Define SWIG build for Python 3
IF(CUSTOM_BUILD_PYTHON3)
	## Package Python3 (linux: python3-dev)
	FIND_PACKAGE(Python3 REQUIRED COMPONENTS Development)
	IF(Python3_FOUND)
		do_raprif_python_swig("3" "${Python3_VERSION}" "${Python3_INCLUDE_DIRS}")
	ENDIF(Python3_FOUND)
ENDIF(CUSTOM_BUILD_PYTHON3)

### Define SWIG build for Python 2
IF(CUSTOM_BUILD_PYTHON2)
	## Package Python2 (linux: python2-dev)
	FIND_PACKAGE(Python2 2.7 REQUIRED COMPONENTS Development)
	IF(Python2_FOUND)
		do_raprif_python_swig("2" "${Python2_VERSION}" "${Python2_INCLUDE_DIRS}")
	ENDIF(Python2_FOUND)
ENDIF(CUSTOM_BUILD_PYTHON2)
