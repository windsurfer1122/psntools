========
psntools
========

:Date:   2021-09-22

.. contents::
   :depth: 3
..

RAP/RIF support
===============

Adds functions to convert RAP to RIF and vice-versa with no dependency
to a special AES implementation, so the develper is free to choose his
preferred AES solution. Additionally it provides the AES ECB/CBC 128-bit
key to encrypt/decrypt RAP keys.

For RIF to RAP process the RIF with the function, then encrypt the
intermediate result to get the RAP. For RAP to RIF decrypt the RAP key,
then process the intermediate result with the function to get the RIF.

C Library for RAP/RIF
---------------------

.. code:: c

   // AES key for RAP key encryption
   const unsigned char * const rap_aes_key;

   // functions
   void rif2rap_rounds(const unsigned char * const in_rif_key, unsigned char * const out_unencrypted_rap_key);
   void rap2rif_rounds(const unsigned char * const in_decrypted_rap_key, unsigned char * const out_rif_key);

Python Module for RAP/RIF
-------------------------

*bytearray* raprif.rap_aes_key
   AES ECB/CBC 128-bit key as bytearray.

*bytearray* raprif.rif2rap_rounds(*bytes|bytearray*)
   Extra processing of RIF key.

*bytearray* raprif.rap2rif_rounds(*bytes|bytearray*)
   Extra processing of decrypted RAP key.

.. code:: python

   from psntools import raprif  # access via raprif.
   #import psntools.raprif  # access via psntools.raprif.
   import binascii

   binascii.hexlify(raprif.rap_aes_key)

   rap_intermediate_bytes = raprif.rif2rap_rounds(rif_bytes)

   rif_bytes = raprif.rap2rif_rounds(rap_intermediate_bytes)

Installation of psntools
========================

psntools for Python
-------------------

As the package includes some C code a C compiler is needed for
installation via ``pip install psntools``.

It is recommended to use virtual environments for `Python
3 <https://docs.python.org/3/tutorial/venv.html>`__ and `Python
2 <https://docs.python-guide.org/dev/virtualenvs/#lower-level-virtualenv>`__
to avoid side-effects with other Python applications. Personal
preference is to use ``.venv3`` and ``.venv2`` respectively to be able
to cross-test for Python 3 and Python 2.

-  Debian-based Linux

   -  Install build environment: ``apt-get install build-essential``.

   -  Install via pip as mentioned above.

-  Windows

   -  Get the *Build Tools* from the `Visual Studio download
      page <https://visualstudio.microsoft.com/downloads/>`__ (link as
      of 2018-11).

      -  Install Build Tools with additional components via "Change…​"
         button:

         -  Desktop Development with C++

      -  Reboot.

   -  Start the Native Tools Command Prompt fitting Python’s bitness
      (x86 = 32.bit, x64 = 64-bit).

   -  Install via pip as mentioned above.

Credits
=======

-  windsurfer1122

-  flatz (RAP/RIF support)
