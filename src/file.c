/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file file.c
 *
 * @author Juuso Alasuutari
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "compat.h"
#include "file.h"

struct file_in
file_read (char const *path)
{
	struct file_in ret = {0};

	do {
		FILE *fp = fopen(path, "rbem");
		if (!fp) {
			ret.ec[0] = errno;
			break;
		}

		do {
			struct stat s = {0};
			ret.ec[0] = fileno(fp);

			ret.ec[0] = ret.ec[0] < 0 || fstat(ret.ec[0], &s);
			if (ret.ec[0]) {
				ret.ec[0] = errno;
				break;
			}

			if ((s.st_mode & S_IFMT) != S_IFREG) {
				ret.ec[0] = EINVAL;
				break;
			}

			if (s.st_size < 0) {
				ret.ec[0] = EIO;
				break;
			}

			ret.size = (size_t)s.st_size;
			ret.data = malloc(ret.size + 1U);
			if (!ret.data) {
				ret.size = 0;
				ret.ec[0] = errno;
				break;
			}

			if (fread(ret.data, 1, ret.size, fp) != ret.size) {
				ret.size = 0;
				ret.ec[0] = errno;
				free(ret.data);
				ret.data = nullptr;
				break;
			}

			ret.data[ret.size] = 0;
		} while (0);

		(void)fclose(fp);
		fp = nullptr;
	} while (0);

	return ret;
}

void
file_in_fini (struct file_in *f)
{
	if (f) {
		free(f->data);
		f->data = nullptr;
		f->size = 0;
	}
}
