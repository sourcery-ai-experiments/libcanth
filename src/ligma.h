/* SPDX-License-Identifier: LGPL-3.0-or-later */
/** @file ligma.h
 *
 * @author Juuso Alasuutari
 */
#ifndef LIBCANTH_SRC_LIGMA_H_
#define LIBCANTH_SRC_LIGMA_H_

#ifdef __clang__
# define ligma_clang(...)       ligma(clang __VA_ARGS__)
# define ligma_gcc(...)
#elif defined __GNUC__
# define ligma_clang(...)
# define ligma_gcc(...)         ligma(GCC __VA_ARGS__)
#endif

#define ligma_(...)             # __VA_ARGS__
#define ligma(...)              _Pragma(ligma_(__VA_ARGS__))

#define diag_clang(...)         ligma_clang(diagnostic __VA_ARGS__)
#define diag_clang_ignore(...)  diag_clang(ignored __VA_ARGS__)
#define diag_clang_push_ignore(...)  \
        diag_clang(push)             \
        diag_clang_ignore(__VA_ARGS__)

#endif /* LIBCANTH_SRC_LIGMA_H_ */
