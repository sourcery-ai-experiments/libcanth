/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file compat_dbg.h
 *
 * @author Juuso Alasuutari
 */
#ifndef LIBCANTH_SRC_COMPAT_DBG_H_
#define LIBCANTH_SRC_COMPAT_DBG_H_

#include "ligma.h"

diag_clang(push)
diag_clang(ignored "-Wgnu-zero-variadic-macro-arguments")

#define pr_(...)            pr__(stderr, ## __VA_ARGS__)
#define pr_out_(...)        pr__(stdout, ## __VA_ARGS__)
#define pr__strerror(fn, e, fmt, ...) do {         \
        pr_##fn(fmt "%s%s", ## __VA_ARGS__,        \
                &"\0: "[!!(fmt)[0]], strerror(e)); \
} while (0)
#define pr_out(fmt, ...)    pr_out_(fmt "\n", ## __VA_ARGS__)
#define pr_wrn_(fmt, ...)   pr_("warning: " fmt "\n", ## __VA_ARGS__)
#define pr_err_(fmt, ...)   pr_(  "error: " fmt "\n", ## __VA_ARGS__)
#define pr_errno_(e, ...)   pr__strerror(err_, (e), ## __VA_ARGS__)
#define pr_wrrno_(e, ...)   pr__strerror(wrn_, (e), ## __VA_ARGS__)
#define pr_wrn(fmt, ...)    pr_wrn_("%s: " fmt, __func__, ## __VA_ARGS__)
#define pr_err(fmt, ...)    pr_err_("%s: " fmt, __func__, ## __VA_ARGS__)
#define pr_errno(e, ...)    pr__strerror(err, (e), ## __VA_ARGS__)
#define pr_wrrno(e, ...)    pr__strerror(wrn, (e), ## __VA_ARGS__)

#ifndef NDEBUG
# define pr_dbg_(fmt, ...)  pr_(       fmt "\n", ## __VA_ARGS__)
# define pr_dbg(fmt, ...)   pr_("%s:%d:%s: " fmt "\n", __FILE__, \
                                __LINE__, __func__, ## __VA_ARGS__)
#endif /* NDEBUG */

diag_clang(pop)

#endif /* LIBCANTH_SRC_COMPAT_DBG_H_ */
