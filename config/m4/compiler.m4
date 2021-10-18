# compiler.m4 - Parsing compiler capabilities
#
# Copyright (C) Mellanox Technologies Ltd. 2001-2020.  ALL RIGHTS RESERVED.
# See file LICENSE for terms.
#


# Check compiler specific attributes
# Usage: CHECK_COMPILER_ATTRIBUTE([attribute], [program], [definition])
# Note:
# - [definition] can be omitted if it is equal to attribute
#
AC_DEFUN([CHECK_COMPILER_ATTRIBUTE], [
    AC_CACHE_VAL(vma_cv_attribute_[$1], [
        #
        # Try to compile using the C compiler
        #
        AC_TRY_COMPILE([$2],[],
                       [vma_cv_attribute_$1=yes],
                       [vma_cv_attribute_$1=no])
        AS_IF([test "x$vma_cv_attribute_$1" = "xyes"], [
            AC_LANG_PUSH(C++)
            AC_TRY_COMPILE([extern "C" {
                           $2
                           }],[],
                           [vma_cv_attribute_$1=yes],
                           [vma_cv_attribute_$1=no])
            AC_LANG_POP(C++)
        ])
    ])
    AC_MSG_CHECKING([for attribute $1])
    AC_MSG_RESULT([$vma_cv_attribute_$1])
    AS_IF([test "x$vma_cv_attribute_$1" = "xyes"], [
        AS_IF([test "x$3" = "x"],
            [AC_DEFINE_UNQUOTED([DEFINED_$1], [1], [Define to 1 if attribute $1 is supported])],
            [AC_DEFINE_UNQUOTED([DEFINED_$3], [1], [Define to 1 if attribute $1 is supported])]
        )
    ])
])

# Check compiler for the specified version of the C++ standard
# Usage: CHECK_COMPILER_CXX([standard], [option], [definition])
# Note:
# - [definition] can be omitted if it is equal to attribute
#
AC_DEFUN([CHECK_COMPILER_CXX], [
    case "$1" in
        11)
m4_define([_vma_cv_compiler_body_11], [[
#ifndef __cplusplus
#error This is not a C++ compiler
#elif __cplusplus < 201103L
#error This is not a C++11 compiler
#else
#include <iostream>
int main(int argc, char** argv)
{
    (void)argc;
    (void)argv;
    /* decltype */
    int a = 5;
    decltype(a) b = a;
    return (b - a);
}
#endif  // __cplusplus >= 201103L
]])
            ;;
        14)
m4_define([_vma_cv_compiler_body_14], [[
#ifndef __cplusplus
#error This is not a C++ compiler
#elif __cplusplus < 201402L
#error This is not a C++14 compiler
#else
#include <iostream>
int main(int argc, char** argv)
{
    (void)argc;
    (void)argv;
    /* Binary integer literals */
    constexpr auto i = 0b0000000000101010;
    static_assert(i == 42, "wrong value");
    return 0;
}
#endif  // __cplusplus >= 201402L
]])
            ;;
        *)
            AC_MSG_ERROR([invalid first argument as [$1] to [$0]])
            ;;
    esac
    case "$2" in
        std)
            vma_cv_option=-std=c++$1
            ;;
        gnu)
            vma_cv_option=-std=gnu++$1
            ;;
        *)
            AC_MSG_ERROR([invalid first argument as [$2] to [$0]])
            ;;
    esac

    AC_CACHE_VAL(vma_cv_compiler_cxx_[$1], [
        vma_cv_compiler_save_CXXFLAGS="$CXXFLAGS"
        CXXFLAGS="$vma_cv_option $CXXFLAGS"

        #
        # Try to compile using the C++ compiler
        #
        AC_LANG_PUSH(C++)
        AC_COMPILE_IFELSE([AC_LANG_SOURCE(_vma_cv_compiler_body_[$1])],
                       [vma_cv_compiler_cxx_$1=yes],
                       [vma_cv_compiler_cxx_$1=no])
        AC_LANG_POP(C++)

        CXXFLAGS="$vma_cv_compiler_save_CXXFLAGS"
    ])
    AC_MSG_CHECKING([for compiler c++ [$1]])
    AC_MSG_RESULT([$vma_cv_compiler_cxx_$1])
    AS_IF([test "x$vma_cv_compiler_cxx_[$1]" = "xyes"],
        [CXXFLAGS="$vma_cv_option $CXXFLAGS"],
        [AC_MSG_ERROR([A compiler with support for C++[$1] language features is required])]
    )
])


##########################
# Set compiler capabilities
#
AC_DEFUN([COMPILER_CAPABILITY_SETUP],
[
CHECK_COMPILER_CXX([11], [std], [])
])