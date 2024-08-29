/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file ucp.h
 *
 * @author Juuso Alasuutari
 */
#include <errno.h>
#include <inttypes.h>

#include "util.h"

/**
 * @brief Unicode code point encoding.
 *
 * These serve a dual purpose: they act as identifiers for different
 * encodings, and their enumeration values themselves are defined as
 * something relevant to that specific encoding. `UCP_UTF8_*` values
 * are the number of bytes when encoding as UTF-8, `UCP_UTF32_*` the
 * maximum amount of data bits the corresponding code points use.
 */
fixed_enum(ucp_kind, uint8_t) {
	UCP_UTF8_1   =  1, //!< UTF-8 encoding, 1 byte
	UCP_UTF8_2   =  2, //!< UTF-8 encoding, 2 bytes
	UCP_UTF8_3   =  3, //!< UTF-8 encoding, 3 bytes
	UCP_UTF8_4   =  4, //!< UTF-8 encoding, 4 bytes
	UCP_UTF32_7  =  7, //!< 1-byte UTF-8 as UTF-32
	UCP_UTF32_11 = 11, //!< 2-byte UTF-8 as UTF-32
	UCP_UTF32_16 = 16, //!< 3-byte UTF-8 as UTF-32
	UCP_UTF32_21 = 21  //!< 4-byte UTF-8 as UTF-32
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
	struct ucp_utf8_1 utf8_1; //!< 1-byte UTF-8.
	struct ucp_utf8_2 utf8_2; //!< 2-byte UTF-8.
	struct ucp_utf8_3 utf8_3; //!< 3-byte UTF-8.
	struct ucp_utf8_4 utf8_4; //!< 4-byte UTF-8.
};

/**
 * @brief Map of UTF-32 to UTF-8.
 */
union ucp_utf32 {
	struct ucp_utf32_7  utf32_7;  //!< 7-bit UTF-32.
	struct ucp_utf32_11 utf32_11; //!< 11-bit UTF-32.
	struct ucp_utf32_16 utf32_16; //!< 16-bit UTF-32.
	struct ucp_utf32_21 utf32_21; //!< 21-bit UTF-32.
};

/**
 * @brief Unicode code point structure.
 *
 * Union-based type for representing Unicode code points in
 * various encodings, moving data bits around between them,
 * and for use as by-value function arguments.
 */
union ucp {
	uint32_t            u32;     //!< Raw 32-bit data view.

	struct ucp_utf32_7  utf32_0; //!< 7b UTF-32/1B UTF-8 view.
	struct ucp_utf32_11 utf32_1; //!< 11b UTF-32/2B UTF-8 view.
	struct ucp_utf32_16 utf32_2; //!< 16b UTF-32/3B UTF-8 view.
	struct ucp_utf32_21 utf32_3; //!< 21b UTF-32/4B UTF-8 view.

	uint8_t             u8[4];   //!< Raw octets view.

	struct ucp_utf8_1   utf8_0;  //!< 1B UTF-8 view.
	struct ucp_utf8_2   utf8_1;  //!< 2B UTF-8 view.
	struct ucp_utf8_3   utf8_2;  //!< 3B UTF-8 view.
	struct ucp_utf8_4   utf8_3;  //!< 4B UTF-8 view.

	unsigned char       data[4]; //!< Raw bytes view.
	char                str[4];  //!< Raw characters view.
};
/**
 * @brief Unicode code point structure.
 *
 * Union-based type for representing Unicode code points in
 * various encodings, moving data bits around between them,
 * and for use as by-value function arguments.
 */
union ucp {
	uint32_t            u32;     //!< Raw 32-bit data view.

	struct ucp_utf32_7  utf32_0; //!< 7b UTF-32/1B UTF-8 view.
	struct ucp_utf32_11 utf32_1; //!< 11b UTF-32/2B UTF-8 view.
	struct ucp_utf32_16 utf32_2; //!< 16b UTF-32/3B UTF-8 view.
	struct ucp_utf32_21 utf32_3; //!< 21b UTF-32/4B UTF-8 view.

	uint8_t             u8[4];   //!< Raw octets view.

	struct ucp_utf8_1   utf8_0;  //!< 1B UTF-8 view.
	struct ucp_utf8_2   utf8_1;  //!< 2B UTF-8 view.
	struct ucp_utf8_3   utf8_2;  //!< 3B UTF-8 view.
	struct ucp_utf8_4   utf8_3;  //!< 4B UTF-8 view.

	unsigned char       data[4]; //!< Raw bytes view.
	char                str[4];  //!< Raw characters view.
};

_Static_assert(sizeof(union ucp) * CHAR_BIT == 32U,"");

#if clang_at_least_version(19)
# define BAD_CODE_POINT (const union ucp){.data = {~0U, ~0U, ~0U, ~0U}}
# define ucp_bad_utf32 (const union ucp){.data = {~0U, ~0U, ~0U, ~0U}}
#else
# define BAD_CODE_POINT (constexpr const union ucp){.u32 = UINT32_MAX}
#endif

static const_inline struct ucp_utf32_7
ucp_utf8_1_to_utf32_7 (const struct ucp_utf8_1 c)
{
	return (struct ucp_utf32_1){
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
		return ucp_bad_utf32;
	}
}
