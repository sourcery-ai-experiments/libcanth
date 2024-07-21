/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file file.h
 *
 * @author Juuso Alasuutari
 */
#ifndef LIBCANTH_SRC_FILE_H_
#define LIBCANTH_SRC_FILE_H_

#include <stddef.h>

#include "util.h"

struct file_in {
	unsigned char *data;
	union {
		size_t size;
		int ec[!(sizeof (size_t) / sizeof (int))
		       + sizeof (size_t) / sizeof (int)];
	};
};

extern struct file_in
file_read (char const *path);

extern void
file_in_fini (struct file_in *f);

static force_inline int
file_error (struct file_in const *f)
{
	return f && !f->data ? f->ec[0] : 0;
}

static force_inline char const *
file_text (struct file_in const *f)
{
	return f && f->data ? (char const *)f->data : "";
}

#endif /* LIBCANTH_SRC_FILE_H_ */
