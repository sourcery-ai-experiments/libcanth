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

# if clang_older_than_version(8)  \
  || gcc_older_than_version(13,1)
#  define fixed_enum(name, T) enum name
# elif clang_older_than_version(18)
#  include "ligma.h"
#  define fixed_enum(name, T)   \
    diag_clang(push)            \
    diag_clang(ignored          \
      "-Wfixed-enum-extension") \
    enum name : T               \
    diag_clang(pop)
# else
#  define fixed_enum(name, T) enum name : T
# endif /* clang < 8 || gcc < 13.1 */

# if clang_older_than_version(19) \
  || gcc_older_than_version(13,1)
#  define constexpr __attribute__((const))
# endif /* clang < 19 || gcc < 13.1 */
#endif /* !__cplusplus */

#endif /* LIBCANTH_SRC_COMPAT_H_ */
