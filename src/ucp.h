/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file ucp.h
 *
 * @author Juuso Alasuutari
 */
#ifndef LIBCANTH_SRC_UCP_H_
#define LIBCANTH_SRC_UCP_H_

#include <limits.h>

#include "util.h"

/**
 * @brief Unicode code point encoding kind.
 */
fixed_enum(ucp_kind, uint8_t) {
	UCP_UTF8_1   =  1, //!< UTF-8, 1 byte (ASCII)
	UCP_UTF8_2   =  2, //!< UTF-8, 2-byte sequence
	UCP_UTF8_3   =  3, //!< UTF-8, 3-byte sequence
	UCP_UTF8_4   =  4, //!< UTF-8, 4-byte sequence
	UCP_UTF32_7  =  7, //!< UTF-32, at most 7 bits
	UCP_UTF32_11 = 11, //!< UTF-32, 8 to 11 bits
	UCP_UTF32_16 = 16, //!< UTF-32, 12 to 16 bits
	UCP_UTF32_21 = 21  //!< UTF-32, 17 to 21 bits
};

/**
 * @brief Map of UTF-32 to 1-byte UTF-8 (ASCII).
 */
struct ucp_utf32_7 {
	uint32_t d0_6   :  7; //!< ASCII byte   [ 0: 6]
	uint32_t p0     : 25; //!<              [ 7:31]
};

/**
 * @brief Map of UTF-32 to 2-byte UTF-8.
 */
struct ucp_utf32_11 {
	uint32_t d0_5   :  6; //!< Cont. byte 1 [ 0: 5]
	uint32_t d6_10  :  5; //!< Leading byte [ 6:10]
	uint32_t p0     : 21; //!<              [11:31]
};

/**
 * @brief Map of UTF-32 to 3-byte UTF-8.
 */
struct ucp_utf32_16 {
	uint32_t d0_5   :  6; //!< Cont. byte 2 [ 0: 5]
	uint32_t d6_11  :  6; //!< Cont. byte 1 [ 6:11]
	uint32_t d12_15 :  4; //!< Leading byte [12:15]
	uint32_t p0     : 16; //!<              [16:31]
};

/**
 * @brief Map of UTF-32 to 4-byte UTF-8.
 */
struct ucp_utf32_21 {
	uint32_t d0_5   :  6; //!< Cont. byte 3 [ 0: 5]
	uint32_t d6_11  :  6; //!< Cont. byte 2 [ 6:11]
	uint32_t d12_17 :  6; //!< Cont. byte 1 [12:17]
	uint32_t d18_20 :  3; //!< Leading byte [18:20]
	uint32_t p0     : 11; //!<              [21:31]
};

/**
 * @brief Map of 1-byte UTF-8 (ASCII) to UTF-32.
 */
struct ucp_utf8_1 {
	uint32_t d0_7   :  7; //!< ASCII byte   [ 0: 6]
	uint32_t p1     : 25; //!<              [ 7:31]
};

/**
 * @brief Map of 2-byte UTF-8 to UTF-32.
 */
struct ucp_utf8_2 {
	uint32_t d6_10  :  5; //!< Leading byte [ 0: 4]
	uint32_t p0     :  3; //!<              [ 5: 7]
	uint32_t d0_5   :  6; //!< Cont. byte 1 [ 8:13]
	uint32_t p1     : 18; //!<              [14:31]
};

/**
 * @brief Map of 3-byte UTF-8 to UTF-32.
 */
struct ucp_utf8_3 {
	uint32_t d12_15 :  4; //!< Leading byte [ 0: 3]
	uint32_t p0     :  4; //!<              [ 4: 7]
	uint32_t d6_11  :  6; //!< Cont. byte 1 [ 8:13]
	uint32_t p1     :  2; //!<              [14:15]
	uint32_t d0_5   :  6; //!< Cont. byte 2 [16:21]
	uint32_t p2     : 10; //!<              [22:31]
};

/**
 * @brief Map of 4-byte UTF-8 to UTF-32.
 */
struct ucp_utf8_4 {
	uint32_t d18_20 :  3; //!< Leading byte [ 0: 2]
	uint32_t p0     :  5; //!<              [ 3: 7]
	uint32_t d12_17 :  6; //!< Cont. byte 1 [ 8:13]
	uint32_t p1     :  2; //!<              [14:15]
	uint32_t d6_11  :  6; //!< Cont. byte 2 [16:21]
	uint32_t p2     :  2; //!<              [22:23]
	uint32_t d0_5   :  6; //!< Cont. byte 3 [24:29]
	uint32_t p3     :  2; //!<              [30:31]
};

/**
 * @brief Map of UTF-8 to UTF-32.
 */
union ucp_utf8 {
	uint8_t           u8[4U]; //!< Raw octets.
	struct ucp_utf8_1 utf8_1; //!< 1-byte UTF-8.
	struct ucp_utf8_2 utf8_2; //!< 2-byte UTF-8.
	struct ucp_utf8_3 utf8_3; //!< 3-byte UTF-8.
	struct ucp_utf8_4 utf8_4; //!< 4-byte UTF-8.
};

/**
 * @brief Map of UTF-32 to UTF-8.
 */
union ucp_utf32 {
	uint32_t            u32;      //!< Raw 32 bits.
	struct ucp_utf32_7  utf32_7;  //!< 7-bit UTF-32.
	struct ucp_utf32_11 utf32_11; //!< 11-bit UTF-32.
	struct ucp_utf32_16 utf32_16; //!< 16-bit UTF-32.
	struct ucp_utf32_21 utf32_21; //!< 21-bit UTF-32.
};

/**
 * @brief Unicode code point view.
 *
 * Union type for mapping Unicode code points to
 * various encodings.
 */
union ucp {
	unsigned char   d[4];  //!< Data bytes.
	union ucp_utf8  utf8;  //!< UTF-8 bytes.
	union ucp_utf32 utf32; //!< UTF-32 value.
};

_Static_assert(sizeof(union ucp) * CHAR_BIT == 32U,"");

#if clang_at_least_version(19)
# define ucp_bad() ((const union ucp){.d={~0U,~0U,~0U,~0U}})
#else
# define ucp_bad() ((constexpr const union ucp){.d={~0U,~0U,~0U,~0U}})
#endif

static const_inline struct ucp_utf32_7
ucp_utf8_1_to_utf32_7 (const struct ucp_utf8_1 c)
{
	return (struct ucp_utf32_7){
		.d0_6 = c.d0_6,
		.p0   = 0
	};
}

static const_inline struct ucp_utf32_11
ucp_utf8_2_to_utf32_11 (const struct ucp_utf8_2 c)
{
	return (struct ucp_utf32_11){
		.d0_5  = c.d0_5,
		.d6_10 = c.d6_10,
		.p0    = 0
	};
}

static const_inline struct ucp_utf32_16
ucp_utf8_3_to_utf32_16 (const struct ucp_utf8_3 c)
{
	return (struct ucp_utf32_16){
		.d0_5   = c.d0_5,
		.d6_11  = c.d6_11,
		.d12_15 = c.d12_15,
		.p0     = 0
	};
}

static const_inline struct ucp_utf32_21
ucp_utf8_4_to_utf32_21 (const struct ucp_utf8_4 c)
{
	return (struct ucp_utf32_21){
		.d0_5   = c.d0_5,
		.d6_11  = c.d6_11,
		.d12_17 = c.d12_17,
		.d18_20 = c.d18_20,
		.p0     = 0
	};
}

static const_inline union ucp_utf32
ucp_utf8_to_utf32 (const union ucp_utf8 c,
                   const enum ucp_kind  k)
{
	switch (k) {
	case UCP_UTF8_1:
		return (union ucp_utf32){
			.utf32_7 = ucp_utf8_1_to_utf32_7(c.utf8_1)
		};
	case UCP_UTF8_2:
		return (union ucp_utf32){
			.utf32_11 = ucp_utf8_2_to_utf32_11(c.utf8_2)
		};
	case UCP_UTF8_3:
		return (union ucp_utf32){
			.utf32_16 = ucp_utf8_3_to_utf32_16(c.utf8_3)
		};
	case UCP_UTF8_4:
		return (union ucp_utf32){
			.utf32_21 = ucp_utf8_4_to_utf32_21(c.utf8_4)
		};
	default:
		return ucp_bad().utf32;
	}
}

static const_inline struct ucp_utf8_1
ucp_utf32_7_to_utf8_1 (const struct ucp_utf32_7 c)
{
	return (struct ucp_utf8_1){
		.d0_6 = c.d0_6,
		.p0   = 0
	};
}

static const_inline struct ucp_utf8_2
ucp_utf32_11_to_utf8_2 (const struct ucp_utf32_11 c)
{
	return (struct ucp_utf8_2){
		.d6_10 = c.d6_10,
		.p0    = 0x6U,
		.d0_5  = c.d0_5,
		.p1    = 0x2U
	};
}

static const_inline struct ucp_utf8_3
ucp_utf32_16_to_utf8_3 (const struct ucp_utf32_16 c)
{
	return (struct ucp_utf8_3){
		.d12_15 = c.d12_15,
		.p0     = 0xeU,
		.d6_11  = c.d6_11,
		.p1     = 0x2U,
		.d0_5   = c.d0_5,
		.p2     = 0x2U
	};
}

static const_inline struct ucp_utf8_4
ucp_utf32_21_to_utf8_4 (const struct ucp_utf32_21 c)
{
	return (struct ucp_utf8_4){
		.d18_20 = c.d18_20,
		.p0     = 0x1eU,
		.d12_17 = c.d12_17,
		.p1     = 0x2U,
		.d6_11  = c.d6_11,
		.p2     = 0x2U,
		.d0_5   = c.d0_5,
		.p3     = 0x2U
	};
}

static const_inline union ucp_utf8
ucp_utf32_to_utf8 (const union ucp_utf32 c,
                   const enum ucp_kind   k)
{
	switch (k) {
	case UCP_UTF32_7:
		return (union ucp_utf8){
			.utf8_1 = ucp_utf32_7_to_utf8_1(c.utf32_7)
		};
	case UCP_UTF32_11:
		return (union ucp_utf8){
			.utf8_2 = ucp_utf32_11_to_utf8_2(c.utf32_11)
		};
	case UCP_UTF32_16:
		return (union ucp_utf8){
			.utf8_3 = ucp_utf32_16_to_utf8_3(c.utf32_16)
		};
	case UCP_UTF32_21:
		return (union ucp_utf8){
			.utf8_4 = ucp_utf32_21_to_utf8_4(c.utf32_21)
		};
	default:
		return ucp_bad().utf8;
	}
}

#endif /* LIBCANTH_SRC_UCP_H_ */
