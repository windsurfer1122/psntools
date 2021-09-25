## https://cmake.org/cmake/help/latest/index.html
CMAKE_MINIMUM_REQUIRED(VERSION 3.13)
## 3.12: +FindPython, -FindPythonLibs
## 3.13: TARGET_SOURCES() relative

## Log some properties for project
MESSAGE(VERBOSE "Python Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
MESSAGE(VERBOSE "++ Python PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}")
MESSAGE(VERBOSE "++ Python PROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}")


## Define macros for builds for Python
MACRO(copy_raprif_python_sdist_bdist py_build_version py_type_prefix)
	## Define copy command for Python sources for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} [pre-built SWIG] Python sources to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
		COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/python/${PROJECT_NAME}.py" "."
		VERBATIM
	)
ENDMACRO(copy_raprif_python_sdist_bdist)

MACRO(copy_raprif_python_sdist py_build_version py_type_prefix)
	## Define copy command for C includes for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} C include directory to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}"
		COMMAND "${CMAKE_COMMAND}" -E copy_directory "${PROJECT_SOURCE_DIR}/include" "include"
		VERBATIM
	)

	## Define copy command for C sources for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} C source directories to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}"
		COMMAND "${CMAKE_COMMAND}" -E copy_directory "${PROJECT_SOURCE_DIR}/src" "src"
		VERBATIM
	)
ENDMACRO(copy_raprif_python_sdist)

MACRO(do_raprif_python py_build_version py_dev_version py_dev_include_dir)
	## >>>>> Define Python environment
	SET(PYTHON_TARGET_NAME_BASE "${PROJECT_NAME}_python${py_build_version}")
	SET(PYTHON_OUTPUT_DIR "target-python${py_build_version}")
	SET(PYTHON_OUTPUT_PATH "${CMAKE_BINARY_DIR}/${PYTHON_OUTPUT_DIR}")
	MESSAGE(VERBOSE "++ PYTHON_OUTPUT_PATH=${PYTHON_OUTPUT_PATH}")
	SET(PYTHON_REQUIRED ">=2.7")


	## >>>>> Define TARGET for BDIST Python extension module
	SET(PYTHON_TARGET_TYPE "bdist")
	ADD_LIBRARY("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		MODULE
	)

	## Define target dependencies for BDIST Python extension module
	ADD_DEPENDENCIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		"${CMAKE_PROJECT_NAME}_python${py_build_version}_${PYTHON_TARGET_TYPE}"
	)

	## Define properties for BDIST Python extension module
	SET_TARGET_PROPERTIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PROPERTIES
			BUILD_WITH_INSTALL_RPATH TRUE
			PREFIX "_"
			LIBRARY_OUTPUT_NAME "${PROJECT_NAME}"
			LIBRARY_OUTPUT_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
			ARCHIVE_OUTPUT_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
			WINDOWS_EXPORT_ALL_SYMBOLS YES CACHE BOOL
	)

	## Define source files (explicitly!) for BDIST Python extension module
	TARGET_SOURCES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRIVATE
			"python/src/${PROJECT_NAME}PYTHON_wrap.c"
			"python/${PROJECT_NAME}.py"
	)

	## Define library dependencies for BDIST Python extension module
	TARGET_LINK_LIBRARIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRIVATE
			"${PROJECT_NAME}"
	)

	## Define include directories for BDIST Python extension module
	TARGET_INCLUDE_DIRECTORIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRIVATE
			${py_dev_include_dir}
	)

	## Define copy commands for BDIST Python extension module
	copy_raprif_python_sdist_bdist("${py_build_version}" "")

	## Log some properties for BDIST Python extension module
	GET_TARGET_PROPERTY(RAPRIF_INCDIRS "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}" INCLUDE_DIRECTORIES)
	GET_TARGET_PROPERTY(RAPRIF_SRCS "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}" SOURCES)
	#
	MESSAGE(VERBOSE "++ Python INCLUDE_DIRECTORIES=${RAPRIF_INCDIRS}")
	MESSAGE(VERBOSE "++ Python SOURCES=${RAPRIF_SRCS}")


	## >>>>> Define TARGET for SDIST Python extension module
	SET(PYTHON_TARGET_TYPE "sdist")
	## Define source files (explicitly!) for SDIST Python extension module
	ADD_CUSTOM_TARGET("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		ALL
		DEPENDS
			"include/raprif.h"
			"src/raprif.c"
			"python/src/${PROJECT_NAME}PYTHON_wrap.c"
			"python/${PROJECT_NAME}.py"
	)

	## Define target dependencies for SDIST Python extension module
	ADD_DEPENDENCIES("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		"${CMAKE_PROJECT_NAME}_python${py_build_version}_${PYTHON_TARGET_TYPE}"
	)

	## Define copy commands for SDIST Python extension module
	copy_raprif_python_sdist_bdist("${py_build_version}" "")
	copy_raprif_python_sdist("${py_build_version}" "")

	## Define copy command for C sources for SDIST Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} [pre-built enhanced SWIG] C source directories to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}"
		COMMAND "${CMAKE_COMMAND}" -E copy_directory "${PROJECT_SOURCE_DIR}/python/src" "src"
		VERBATIM
	)
ENDMACRO(do_raprif_python)


## Define SWIG build for Python 3
IF(CUSTOM_BUILD_PYTHON3)
	## Package Python3 (linux: python3-dev)
	FIND_PACKAGE(Python3 REQUIRED COMPONENTS Development)
	IF(Python3_FOUND)
		do_raprif_python("3" "${Python3_VERSION}" "${Python3_INCLUDE_DIRS}")
	ENDIF(Python3_FOUND)
ENDIF(CUSTOM_BUILD_PYTHON3)

### Define SWIG build for Python 2
IF(CUSTOM_BUILD_PYTHON2)
	## Package Python2 (linux: python2-dev)
	FIND_PACKAGE(Python2 2.7 REQUIRED COMPONENTS Development)
	IF(Python2_FOUND)
		do_raprif_python("2" "${Python2_VERSION}" "${Python2_INCLUDE_DIRS}")
	ENDIF(Python2_FOUND)
ENDIF(CUSTOM_BUILD_PYTHON2)
