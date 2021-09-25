/*
	SWIG interface source for raprif
	Copyright (C) 2021  windsurfer1122

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

%define DOCSTRING
#if defined(SWIGPYTHON)
"Python module for RAP/RIF conversions written in C"
#endif // defined(SWIG<language>)
%enddef

%module(docstring=DOCSTRING) raprif

%include <constraints.i>
#if !defined(SWIGPYTHON)
%apply Pointer NONNULL { unsigned char * };
#endif // !defined(SWIG<language>)

%include <cstring.i>
%cstring_output_allocate_size(unsigned char ** const out_raprif_key, size_t * const out_raprif_key_size, free(*$1));

#if defined(SWIGPYTHON)
	%typemap(in) unsigned char * {
		Py_ssize_t len;
		if (PyBytes_Check($input)) {
			len = PyBytes_Size($input);
			$1 = (unsigned char *) PyBytes_AsString($input);
		} else if (PyByteArray_Check($input)) {
			len = PyByteArray_Size($input);
			$1 = (unsigned char *) PyByteArray_AsString($input);
		} else {
			PyErr_SetString(PyExc_TypeError, "$symname: Type of argument #$argnum is neither bytes nor bytearray.");
			SWIG_fail;
		}
		if (len < RAPRIF_KEYSIZE_RAPRIF) {
			PyErr_SetString(PyExc_ValueError, "$symname: Size of argument #$argnum is less than raprif.RAPRIF_KEYSIZE_RAPRIF.");
			SWIG_fail;
		}
		// re-create "constraints.i/%apply Pointer NONNULL" via typemap, enhance message with function name and argument number
		if (!$1) {
			PyErr_SetString(PyExc_ValueError, "$symname: Argument #$argnum received a NULL pointer.");
			SWIG_fail;
		}
	}

	%typemap(varout) unsigned char * {
		$result = PyByteArray_FromStringAndSize((char *) $1, RAPRIF_KEYSIZE_AES);
	}
#else
	#error "No typemaps are defined (e.g. unsigned char *)"
#endif // SWIG<language>

%{
/* Put headers and other declarations here */
#if defined(SWIGPYTHON)
#define SWIG_FILE_WITH_INIT
#endif // SWIGPYTHON

#include "raprif.h"
%}

/* Parse the header file to generate wrappers */
%ignore rif2rap_rounds;
%ignore rap2rif_rounds;
#if defined(SWIGPYTHON)
%rename("$ignore", regexmatch$name="^RAPRIF_VERSION_") "";
%rename(__version__) RAPRIF_VERSION;
#endif // SWIGPYTHON
%include "../include/raprif.h"
%rename(rif2rap_rounds) swig_rif2rap_rounds;
%rename(rap2rif_rounds) swig_rap2rif_rounds;
%inline %{
void swig_rif2rap_rounds(const unsigned char * const in_rif_key, unsigned char ** const out_raprif_key, size_t * const out_raprif_key_size)
{
  *out_raprif_key = (unsigned char *) malloc(RAPRIF_KEYSIZE_RAPRIF);
  if (*out_raprif_key) {
    *out_raprif_key_size = RAPRIF_KEYSIZE_RAPRIF;
    rif2rap_rounds(in_rif_key,*out_raprif_key);
  }
}

void swig_rap2rif_rounds(const unsigned char * const in_decrypted_rap_key, unsigned char ** const out_raprif_key, size_t * const out_raprif_key_size)
{
  *out_raprif_key = (unsigned char *) malloc(RAPRIF_KEYSIZE_RAPRIF);
  if (*out_raprif_key) {
    *out_raprif_key_size = RAPRIF_KEYSIZE_RAPRIF;
    rap2rif_rounds(in_decrypted_rap_key,*out_raprif_key);
  }
}
%}
