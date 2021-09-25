/*
	Implementation in C for raprif 
	Copyright (C) 2021  windsurfer1122 & flatz

	Provide special round logic fpr RAP/RIF conversions without any
	dependency to any crypto library, so it can be used everywhere
	and easily be converted for other languages (e.g. Python).

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

#include <string.h> // memcpy()

#include "raprif.h"


// AES key for RAP encryption
const unsigned char * const rap_aes_key = (unsigned char[]) {
	0x86, 0x9F, 0x77, 0x45, 0xC1, 0x3F, 0xD8, 0x90, 0xCC, 0xF2, 0x91, 0x88, 0xE3, 0xCC, 0x3E, 0xDF
};


// RAP/RIF conversion round data
static unsigned char pbox[RAPRIF_KEYSIZE_RAPRIF] = {
	0x0C, 0x03, 0x06, 0x04, 0x01, 0x0B, 0x0F, 0x08, 0x02, 0x07, 0x00, 0x05, 0x0A, 0x0E, 0x0D, 0x09
};
static unsigned char e1[RAPRIF_KEYSIZE_RAPRIF] = {
	0xA9, 0x3E, 0x1F, 0xD6, 0x7C, 0x55, 0xA3, 0x29, 0xB7, 0x5F, 0xDD, 0xA6, 0x2A, 0x95, 0xC7, 0xA5
};
static unsigned char e2[RAPRIF_KEYSIZE_RAPRIF] = {
	0x67, 0xD4, 0x5D, 0xA3, 0x29, 0x6D, 0x00, 0x6A, 0x4E, 0x7C, 0x53, 0x7B, 0xF5, 0x53, 0x8C, 0x74
};


// RIF to RAP conversion without AES encryption, therefore RAP key needs to be encrypted afterwards
void rif2rap_rounds(const unsigned char * const in_rif_key, unsigned char * const out_unencrypted_rap_key)
{
	memcpy(out_unencrypted_rap_key, in_rif_key, RAPRIF_KEYSIZE_RAPRIF); // initialize RAP key with RIF key

	for (int round_num = 0; round_num < 5; ++round_num)
	{
		// add e2 byte array to out_unencrypted_rap_key byte array in byte order of pbox array
		unsigned char carry_over = 0;
		for (int i = 0; i < RAPRIF_KEYSIZE_RAPRIF; ++i)
		{
			int p = pbox[i];
			unsigned char ec2 = e2[p];
			//
			unsigned char kc = out_unencrypted_rap_key[p] + ec2;
			out_unencrypted_rap_key[p] = kc + carry_over;
			// highest result: 0xff + 0xff + 1 = 0xff with a carry over of 1
			// special case: carry over could cause another carry over only if intermediate result kc is 0xff, then just keep carry over (no change)
			// otherwise carry over could occur only if intermediate result kc became less than addition value ec2
			if (carry_over != 1 || kc != 0xFF)
			{
				carry_over = kc < ec2 ? 1 : 0;
			}
		}
		// xor out_unencrypted_rap_key byte array with its alternating self shifted by 1 in byte order of pbox array
		// e.g. xor 2nd out_unencrypted_rap_key byte in pbox order with 1st out_unencrypted_rap_key byte in pbox order ([1]<[0],[2]<[1],...,[15]<[14])
		for (int i = 1; i < RAPRIF_KEYSIZE_RAPRIF; ++i)
		{
			int p = pbox[i];
			int pp = pbox[i - 1];
			out_unencrypted_rap_key[p] ^= out_unencrypted_rap_key[pp];
		}
		// xor out_unencrypted_rap_key byte array with e1 byte array (order does not matter)
		for (int i = 0; i < RAPRIF_KEYSIZE_RAPRIF; ++i)
		{
			out_unencrypted_rap_key[i] ^= e1[i];
		}
	}

	return;
}

// RAP to RIF conversion without AES decryption, therefore needs an already decrypted RAP key
void rap2rif_rounds(const unsigned char * const in_decrypted_rap_key, unsigned char * const out_rif_key)
{
	memcpy(out_rif_key, in_decrypted_rap_key, RAPRIF_KEYSIZE_RAPRIF); // initialize RIF key with decrypted RAP key

	for (int round_num = 0; round_num < 5; ++round_num)
	{
		// xor out_rif_key byte array with e1 byte array (order does not matter)
		for (int i = 0; i < RAPRIF_KEYSIZE_RAPRIF; ++i)
		{
			out_rif_key[i] ^= e1[i];
		}
		// xor out_rif_key byte array with its alternating self shifted by 1 in reversed byte order of pbox array
		// e.g. xor 2nd out_rif_key byte in pbox order with 1st out_rif_key byte in pbox order ([15]<[14],[14]<[13],...,[1]<[0])
		for (int i = (RAPRIF_KEYSIZE_RAPRIF - 1); i >= 1; --i)
		{
			int p = pbox[i];
			int pp = pbox[i - 1];
			out_rif_key[p] ^= out_rif_key[pp];
		}
		// subtract e2 byte array from out_rif_key byte array in byte order of pbox array
		unsigned char carry_over = 0;
		for (int i = 0; i < RAPRIF_KEYSIZE_RAPRIF; ++i)
		{
			int p = pbox[i];
			unsigned char ec2 = e2[p];
			//
			unsigned char kc = out_rif_key[p] - carry_over;
			out_rif_key[p] = kc - ec2;
			// lowest result: 0x00 - 1 - 0xff = 0x00 with a carry over of 1
			// special case: carry over could cause another carry over only if intermediate result kc became 0xff (=0x00 - 1), then just keep carry over (no change)
			// otherwise carry over could occur only if intermediate result kc is less than subtraction value ec2
			if (carry_over != 1 || kc != 0xFF)
			{
				carry_over = kc < ec2 ? 1 : 0;
			}
		}
	}

	return;
}
