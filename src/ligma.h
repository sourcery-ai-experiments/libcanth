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

#define diag_clang(...)                            \
        ligma_clang(diagnostic          __VA_ARGS__)
#define diag_clang_ignore(...)                     \
        ligma_clang(diagnostic ignored  __VA_ARGS__)
#define diag_clang_push_ignore(...)                \
        ligma_clang(diagnostic push)               \
        ligma_clang(diagnostic ignored  __VA_ARGS__)

#define diag_gcc(...)                              \
        ligma_gcc(diagnostic            __VA_ARGS__)
#define diag_gcc_ignore(...)                       \
        ligma_gcc(diagnostic ignored    __VA_ARGS__)
#define diag_gcc_push_ignore(...)                  \
        ligma_gcc(diagnostic push)                 \
        ligma_gcc(diagnostic ignored    __VA_ARGS__)

#endif /* LIBCANTH_SRC_LIGMA_H_ */
