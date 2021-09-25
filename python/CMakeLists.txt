## https://cmake.org/cmake/help/latest/index.html
CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
## 3.0: Basis, PROJECT(VERSION)

## Log some properties for project
MESSAGE(VERBOSE "Python Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
MESSAGE(VERBOSE "++ Python PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}")
MESSAGE(VERBOSE "++ Python PROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}")


## Define macros for builds for Python
MACRO(configure_psntools_python py_build_version py_type_prefix)
	## Configure files for setuptools for Python extension module
	MESSAGE(STATUS "Configure ${PROJECT_NAME} Python setuptools files to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree")
	CONFIGURE_FILE(
		"python/setup.py.in" "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/setup.py"
			@ONLY
	)
ENDMACRO(configure_psntools_python)

MACRO(copy_psntools_python_sdist_bdist py_build_version py_type_prefix)
	## Define make directory command for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		PRE_BUILD
		COMMENT "Creating ${PROJECT_NAME} directory structure in Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		COMMAND "${CMAKE_COMMAND}" -E make_directory "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
		VERBATIM
	)

	## Define copy+rename command for README for Python extension module
	#ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
	#	POST_BUILD
	#	COMMENT "Copying ${PROJECT_NAME} README to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
	#	WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}"
	#	COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_SOURCE_DIR}/README.adoc" "README.txt"
	#	VERBATIM
	#)

	## Define copy command for Python sources for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} Python sources to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}/${CMAKE_PROJECT_NAME}"
		COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_SOURCE_DIR}/python/__init__.py" "."
		VERBATIM
	)

	## Define copy command for Python setuptools files for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} Python setuptools files to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}"
		COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_SOURCE_DIR}/README.rst" "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt" "."
		VERBATIM
	)
ENDMACRO(copy_psntools_python_sdist_bdist)

MACRO(copy_psntools_python_sdist py_build_version py_type_prefix)
	## Define copy command for Python setuptools files for Python extension module
	ADD_CUSTOM_COMMAND(TARGET "${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		POST_BUILD
		COMMENT "Copying ${PROJECT_NAME} Python setuptools files to Python ${py_build_version} ${CMAKE_PROJECT_NAME} ${py_type_prefix}${PYTHON_TARGET_TYPE} tree"
		WORKING_DIRECTORY "${PYTHON_OUTPUT_PATH}/${PYTHON_TARGET_TYPE}"
		COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/python/pyproject.toml" "${CMAKE_CURRENT_SOURCE_DIR}/python/MANIFEST.in" "."
		VERBATIM
	)
ENDMACRO(copy_psntools_python_sdist)

MACRO(do_psntools_python py_build_version)
	## >>>>> Define Python environment
	SET(PYTHON_TARGET_NAME_BASE "${PROJECT_NAME}_python${py_build_version}")
	SET(PYTHON_OUTPUT_DIR "target-python${py_build_version}")
	SET(PYTHON_OUTPUT_PATH "${CMAKE_BINARY_DIR}/${PYTHON_OUTPUT_DIR}")
	MESSAGE(VERBOSE "++ PYTHON_OUTPUT_PATH=${PYTHON_OUTPUT_PATH}")
	SET(PYTHON_REQUIRED ">=2.7")


	## >>>>> Define TARGET for BDIST Python extension module
	SET(PYTHON_TARGET_TYPE "bdist")
	## Define source files (explicitly!) for BDIST Python extension module
	ADD_CUSTOM_TARGET("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		ALL
		DEPENDS
			"LICENSE.txt"
			"README.rst"
			"python/setup.py.in"
			"python/__init__.py"
	)

	## Configure files for setuptools for BDIST Python extension module
	configure_psntools_python("${py_build_version}" "")

	## Define make directory and copy commands for BDIST Python extension module
	copy_psntools_python_sdist_bdist("${py_build_version}" "")


	## >>>>> Define TARGET for SDIST Python extension module
	SET(PYTHON_TARGET_TYPE "sdist")
	## Define source files (explicitly!) for SDIST Python extension module
	ADD_CUSTOM_TARGET("${PYTHON_TARGET_NAME_BASE}_${PYTHON_TARGET_TYPE}"
		ALL
		DEPENDS
			"LICENSE.txt"
			"README.rst"
			"python/setup.py.in"
			"python/__init__.py"
			"python/pyproject.toml"
			"python/MANIFEST.in"
	)

	## Configure files for setuptools for SDIST Python extension module
	configure_psntools_python("${py_build_version}" "")

	## Define make directory and copy commands for SDIST Python extension module
	copy_psntools_python_sdist_bdist("${py_build_version}" "")
	copy_psntools_python_sdist("${py_build_version}" "")
ENDMACRO(do_psntools_python)


## Define build for Python 3
IF(CUSTOM_BUILD_PYTHON3)
	do_psntools_python("3")
ENDIF(CUSTOM_BUILD_PYTHON3)

### Define build for Python 2
IF(CUSTOM_BUILD_PYTHON2)
	do_psntools_python("2")
ENDIF(CUSTOM_BUILD_PYTHON2)
