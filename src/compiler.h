/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file compiler.h
 *
 * @author Juuso Alasuutari
 */
#ifndef LIBCANTH_SRC_COMPILER_H_
#define LIBCANTH_SRC_COMPILER_H_

#include "util.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

extern const_nonnull char const *canth_c_version (void);
extern const_nonnull char const *canth_cxx_version (void);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* LIBCANTH_SRC_COMPILER_H_ */
