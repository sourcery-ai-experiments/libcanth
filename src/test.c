/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file test.c
 *
 * @author Juuso Alasuutari
 */
#include "ligma.h"

diag_apple_clang(push)
diag_apple_clang(ignored "-Wpadded")

#include <cjson/cJSON.h>

#include "compiler.h"
#include "dbg.h"
#include "dstr.h"

int
main (int    argc,
      char **argv)
{
	pr_out("%s / %s", canth_c_version(), canth_cxx_version());

	for (int i = 0; ++i < argc;) {
		cJSON *json = cJSON_Parse(argv[i]);
		if (!json) {
			const char *s = cJSON_GetErrorPtr();
			if (s)
				pr_err("cJSON_Parse: before: %s", s);
			continue;
		}
		cJSON_Delete(json);
	}
}

diag_apple_clang(pop)
