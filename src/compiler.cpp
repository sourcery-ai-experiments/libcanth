/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file cxx.cpp
 *
 * @author Juuso Alasuutari
 */
#include "util.h"

namespace {
	constexpr const char version_string[] =
#ifdef __clang__
	        "clang++ " stringify(__clang_major__) "."
	                   stringify(__clang_minor__) "."
	                   stringify(__clang_patchlevel__);
#else
	        "g++ " stringify(__GNUC__)       "."
	               stringify(__GNUC_MINOR__) "."
	               stringify(__GNUC_PATCHLEVEL__);
#endif
}

extern "C" {
	extern char const *canth_cxx_version (void);

	char const *
	canth_cxx_version (void)
	{
		return &version_string[0];
	}
}
