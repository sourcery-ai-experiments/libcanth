#ifndef LIBCANTH_MK_CC_H_
#define LIBCANTH_MK_CC_H_

#define set(var,...)    eval(var:=__VA_ARGS__)
#define clr(var)        eval(undefine var)
#define eval(...)       $(eval override __VA_ARGS__)
#define def(var)        cat(__default_,v(var))
#define v(...)          cat(pfx(),__VA_ARGS__)
#define cat(a,b)        cat_(a,b)
#define cat_(a,b)       a##b

#ifndef __cplusplus
# define pfx() c
# ifdef __clang_major__
#  if __clang_major__ > 17
#   define std() gnu23
#  elif __clang_major__ > 8
#   define std() gnu2x
#  endif /* __clang_major__ */
# elif defined __GNUC__
#  if __GNUC__ > 13
#   define std() gnu23
#  elif __GNUC__ > 8
#   define std() gnu2x
#  endif /* __GNUC__ */
# endif /* __clang_major__ || __GNUC__ */
#else /* __cplusplus */
# define pfx() cxx
# ifdef __clang_major__
#  if __clang_major__ > 16
#   define std() gnu++23
#  elif __clang_major__ > 11
#   define std() gnu++2b
#  elif __clang_major__ > 9
#   define std() gnu++20
#  elif __clang_major__ > 4
#   define std() gnu++2a
#  endif /* __clang_major__ */
# elif defined __GNUC__
#  if __GNUC__ > 10
#   define std() gnu++23
#  elif __GNUC__ > 9
#   define std() gnu++20
#  elif __GNUC__ > 7
#   define std() gnu++2a
#  endif /* __GNUC__ */
# endif /* __clang_major__ || __GNUC__ */
#endif /* __cplusplus */

#ifdef __GNUC__
# pragma push_macro("__GNUC__")
# undef __GNUC__
# define __GNUC__() set(v,v(__GNUC__))_Pragma("pop_macro(\"__GNUC__\")")set($v,__GNUC__)
#else
# define __GNUC__() clr(v(__GNUC__))
#endif

#ifdef __GNUC_MINOR__
# pragma push_macro("__GNUC_MINOR__")
# undef __GNUC_MINOR__
# define __GNUC_MINOR__() set(v,v(__GNUC_MINOR__))_Pragma("pop_macro(\"__GNUC_MINOR__\")")set($v,__GNUC_MINOR__)
#else
# define __GNUC_MINOR__() clr(v(__GNUC_MINOR__))
#endif

#ifdef __GNUC_PATCHLEVEL__
# pragma push_macro("__GNUC_PATCHLEVEL__")
# undef __GNUC_PATCHLEVEL__
# define __GNUC_PATCHLEVEL__() set(v,v(__GNUC_PATCHLEVEL__))_Pragma("pop_macro(\"__GNUC_PATCHLEVEL__\")")set($v,__GNUC_PATCHLEVEL__)
#else
# define __GNUC_PATCHLEVEL__() clr(v(__GNUC_PATCHLEVEL__))
#endif

#ifdef __clang_major__
# pragma push_macro("__clang_major__")
# undef __clang_major__
# define __clang_major__() set(v,v(__clang_major__))_Pragma("pop_macro(\"__clang_major__\")")set($v,__clang_major__)
#else
# define __clang_major__() clr(v(__clang_major__))
#endif

#ifdef __clang_minor__
# pragma push_macro("__clang_minor__")
# undef __clang_minor__
# define __clang_minor__() set(v,v(__clang_minor__))_Pragma("pop_macro(\"__clang_minor__\")")set($v,__clang_minor__)
#else
# define __clang_minor__() clr(v(__clang_minor__))
#endif

#ifdef __clang_patchlevel__
# pragma push_macro("__clang_patchlevel__")
# undef __clang_patchlevel__
# define __clang_patchlevel__() set(v,v(__clang_patchlevel__))_Pragma("pop_macro(\"__clang_patchlevel__\")")set($v,__clang_patchlevel__)
#else
# define __clang_patchlevel__() clr(v(__clang_patchlevel__))
#endif

#ifdef std
set(def(std),std())
#else /* std */
clr(def(std))
#endif /* std */

__GNUC__()
__GNUC_MINOR__()
__GNUC_PATCHLEVEL__()
__clang_major__()
__clang_minor__()
__clang_patchlevel__()

clr(v)

#endif /* LIBCANTH_MK_CC_H_ */
