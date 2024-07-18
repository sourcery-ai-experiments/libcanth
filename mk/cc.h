#ifndef LIBCANTH_MK_CC_H_
#define LIBCANTH_MK_CC_H_

#define set(var,...)    eval(var:=__VA_ARGS__)
#define clr(var)        eval(undefine var)
#define eval(...)       $(eval override __VA_ARGS__)
#define def(v)          cat(q(__default_),cat2(_,v))
#define p(...)          cat(lang(),__VA_ARGS__)
#define q(...)          cat(__VA_ARGS__,lang())
#define cat(a,b)        cat_(a,b)
#define cat_(a,b)       a##b
#define cat2(a,b)       cat2_(a,b)
#define cat2_(a,b)      a##b

#undef arch
#undef cpu
#undef std
#undef tune

#if !defined(__APPLE__) || defined(__clang__) || (__GNUC__ < 12)
# define arch() native
# define tune() native
#endif

#ifndef __cplusplus
# define lang() c
# undef no_va_opt

# ifdef __clang_major__
#  if __clang_major__ < 12
#   define no_va_opt() 1
#  endif /* __clang_major__ < 12 */
#  if __clang_major__ > 17
#   define std() gnu23
#  elif __clang_major__ > 8
#   define std() gnu2x
#  elif __clang_major__ > 7
#   define std() gnu18
#  elif __clang_major__ > 5
#   define std() gnu17
#  elif __clang_major__ > 3 || (__clang_major__ == 3 && __clang_minor__ > 0)
#   define std() gnu11
#  endif /* __clang_major__ */

# elif defined __GNUC__
#  if __GNUC__ < 8
#   define no_va_opt() 1
#  endif /* __GNUC__ < 8 */
#  if __GNUC__ > 13
#   define std() gnu23
#  elif __GNUC__ > 8
#   define std() gnu2x
#  elif __GNUC__ > 7
#   define std() gnu18
#  elif __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ > 6)
#   define std() gnu11
#  endif /* __GNUC__ */
# endif /* __clang_major__ || __GNUC__ */

#else /* __cplusplus */
# define lang() cxx

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

#ifdef __APPLE__
# pragma push_macro("__APPLE__")
# undef __APPLE__
# define __APPLE__() set(v,p(__APPLE__))_Pragma("pop_macro(\"__APPLE__\")")set($v,__APPLE__)
__APPLE__()
#else
clr(p(__APPLE__))
#endif

#ifdef __GNUC__
# pragma push_macro("__GNUC__")
# undef __GNUC__
# define __GNUC__() set(v,p(__GNUC__))_Pragma("pop_macro(\"__GNUC__\")")set($v,__GNUC__)
__GNUC__()
#else
clr(p(__GNUC__))
#endif

#ifdef __GNUC_MINOR__
# pragma push_macro("__GNUC_MINOR__")
# undef __GNUC_MINOR__
# define __GNUC_MINOR__() set(v,p(__GNUC_MINOR__))_Pragma("pop_macro(\"__GNUC_MINOR__\")")set($v,__GNUC_MINOR__)
__GNUC_MINOR__()
#else
clr(p(__GNUC_MINOR__))
#endif

#ifdef __GNUC_PATCHLEVEL__
# pragma push_macro("__GNUC_PATCHLEVEL__")
# undef __GNUC_PATCHLEVEL__
# define __GNUC_PATCHLEVEL__() set(v,p(__GNUC_PATCHLEVEL__))_Pragma("pop_macro(\"__GNUC_PATCHLEVEL__\")")set($v,__GNUC_PATCHLEVEL__)
__GNUC_PATCHLEVEL__()
#else
clr(p(__GNUC_PATCHLEVEL__))
#endif

#ifdef __clang_major__
# pragma push_macro("__clang_major__")
# undef __clang_major__
# define __clang_major__() set(v,p(__clang_major__))_Pragma("pop_macro(\"__clang_major__\")")set($v,__clang_major__)
__clang_major__()
#else
clr(p(__clang_major__))
#endif

#ifdef __clang_minor__
# pragma push_macro("__clang_minor__")
# undef __clang_minor__
# define __clang_minor__() set(v,p(__clang_minor__))_Pragma("pop_macro(\"__clang_minor__\")")set($v,__clang_minor__)
__clang_minor__()
#else
clr(p(__clang_minor__))
#endif

#ifdef __clang_patchlevel__
# pragma push_macro("__clang_patchlevel__")
# undef __clang_patchlevel__
# define __clang_patchlevel__() set(v,p(__clang_patchlevel__))_Pragma("pop_macro(\"__clang_patchlevel__\")")set($v,__clang_patchlevel__)
__clang_patchlevel__()
#else
clr(p(__clang_patchlevel__))
#endif

clr(v)

#ifdef arch
set(def(arch),arch())
#else /* arch */
clr(def(arch))
#endif /* arch */

#ifdef cpu
set(def(cpu),cpu())
#else /* cpu */
clr(def(cpu))
#endif /* cpu */

#ifndef __cplusplus
# ifdef no_va_opt
set(def(no_va_opt),no_va_opt())
# else /* no_va_opt */
clr(def(no_va_opt))
# endif /* no_va_opt */
#endif /* !__cplusplus */

#ifdef std
set(def(std),std())
#else /* std */
clr(def(std))
#endif /* std */

#ifdef tune
set(def(tune),tune())
#else /* tune */
clr(def(tune))
#endif /* tune */

#endif /* LIBCANTH_MK_CC_H_ */
