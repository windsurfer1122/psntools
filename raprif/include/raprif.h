/*
	Header file for raprif
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

#ifndef _RAPRIF_H
#define _RAPRIF_H

#define RAPRIF_VERSION_MAJOR "1"
#define RAPRIF_VERSION_MINOR "0"
#define RAPRIF_VERSION_MICRO "0"
#define RAPRIF_VERSION RAPRIF_VERSION_MAJOR "." RAPRIF_VERSION_MINOR "." RAPRIF_VERSION_MICRO

// key sizes
#define RAPRIF_KEYSIZE_AES 16
#define RAPRIF_KEYSIZE_RAPRIF 16

#ifdef __cplusplus
extern "C" {
#endif

// AES key for RAP key encryption
const unsigned char * const rap_aes_key;

// functions
void rif2rap_rounds(const unsigned char * const in_rif_key, unsigned char * const out_unencrypted_rap_key);
void rap2rif_rounds(const unsigned char * const in_decrypted_rap_key, unsigned char * const out_rif_key);

#ifdef __cplusplus
}
#endif

#endif /* raprif.h */
