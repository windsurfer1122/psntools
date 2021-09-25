## https://cmake.org/cmake/help/latest/index.html
CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
## 3.0: Basis, PROJECT(VERSION)

## Log some properties for project
MESSAGE(VERBOSE "SWIG Project: ${PROJECT_NAME} ${PROJECT_VERSION}")
MESSAGE(VERBOSE "++ SWIG PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}")
MESSAGE(VERBOSE "++ SWIG PROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}")


## Define macros for SWIG builds for Python
MACRO(do_psntools_python_swig py_build_version)
	## >>>>> Define Python environment
	SET(PYTHON_TARGET_NAME_BASE "${PROJECT_NAME}_python${py_build_version}_swig")
	SET(PYTHON_OUTPUT_DIR "target-python${py_build_version}-swig")
	SET(PYTHON_OUTPUT_PATH "${CMAKE_BINARY_DIR}/${PYTHON_OUTPUT_DIR}")
	MESSAGE(VERBOSE "++ PYTHON_OUTPUT_PATH=${PYTHON_OUTPUT_PATH}")
	SET(PYTHON_REQUIRED ">=2.7")


	## >>>>> Define TARGET for SWIG BDIST Python extension module
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

	## Configure files for setuptools for SWIG BDIST Python extension module
	configure_psntools_python("${py_build_version}" "SWIG ")

	## Define make directory and copy commands for BDIST Python extension module
	copy_psntools_python_sdist_bdist("${py_build_version}" "SWIG ")


	## >>>>> Define TARGET for SWIG SDIST Python extension module
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

	## Configure files for setuptools for SWIG SDIST Python extension module
	configure_psntools_python("${py_build_version}" "SWIG ")

	## Define make directory and copy commands for SDIST Python extension module
	copy_psntools_python_sdist_bdist("${py_build_version}" "SWIG ")
	copy_psntools_python_sdist("${py_build_version}" "SWIG ")
ENDMACRO(do_psntools_python_swig)


## Define SWIG build for Python 3
IF(CUSTOM_BUILD_PYTHON3)
	do_psntools_python_swig("3")
ENDIF(CUSTOM_BUILD_PYTHON3)

### Define SWIG build for Python 2
IF(CUSTOM_BUILD_PYTHON2)
	do_psntools_python_swig("2")
ENDIF(CUSTOM_BUILD_PYTHON2)
