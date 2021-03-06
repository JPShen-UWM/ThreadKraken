//////////////////////////////////////////////////////////////////////////////
//
//    CLASS - Cloud Loader and ASsembler System
//    Copyright (C) 2021 Winor Chen
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License along
//    with this program; if not, write to the Free Software Foundation, Inc.,
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __MTSSTREAM_H__
#define __MTSSTREAM_H__
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdint>
#include "primitives.h"
#include "priscas_global.h"
#include "mt_exception.h"

namespace priscas
{

	class asm_ostream
	{
		public:	

			enum STREAM_TYPE
			{
				BIN,
				MIF,
				HEX
			};

			void append(uint8_t* begin, size_t count);
			asm_ostream(const char * filename, STREAM_TYPE stin);
			~asm_ostream();

			void set_mode(STREAM_TYPE stin) { this->st = stin; }
			void set_width(size_t newwidth) { this->width = newwidth; }
			void finalize();

		private:
			FILE * f;
			asm_ostream(asm_ostream &);
			asm_ostream& operator=(asm_ostream &);

			STREAM_TYPE st;

			UPString_Vec mif_insts;
			size_t width;
			size_t total_bytes;
	};
}

#endif
