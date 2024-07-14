/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file compiler.c
 *
 * @author Juuso Alasuutari
 */
#include "util.h"

extern char const *canth_c_version (void);

char const *
canth_c_version (void)
{
	constexpr static const char version_string[] =
#ifdef __clang__
	        "clang " stringify(__clang_major__) "."
	                 stringify(__clang_minor__) "."
	                 stringify(__clang_patchlevel__);
#else
	        "gcc " stringify(__GNUC__)       "."
	               stringify(__GNUC_MINOR__) "."
	               stringify(__GNUC_PATCHLEVEL__);
#endif
	return version_string;
}
