/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file compat.h
 *
 * @author Juuso Alasuutari
 */
#ifndef LIBCANTH_SRC_COMPAT_H_
#define LIBCANTH_SRC_COMPAT_H_

#ifndef __cplusplus
# include "compiler.h"

# if clang_older_than_version(16) \
  || gcc_older_than_version(13,1)
#  include <stddef.h>
#  define nullptr NULL
# endif /* clang < 16 || gcc < 13.1 */

# if clang_older_than_version(19) \
  || gcc_older_than_version(13,1)
#  define constexpr __attribute__((const))
# endif /* clang < 19 || gcc < 13.1 */
#endif /* !__cplusplus */

#endif /* LIBCANTH_SRC_COMPAT_H_ */
