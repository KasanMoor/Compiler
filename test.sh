#!/bin/bash
echo Redeclaration: Expecting one error
./120++ test/reDecl.cpp
echo
echo Scope nesting: Expecting one error on int rip
./120++ test/nestedDecl.cpp
echo
echo Single Declaration: expecting one error on hi
./120++ test/singleDecl.cpp
echo
echo syntax error test: expected one error
./120++ test/syntaxError.cpp
echo
echo Multiple decls on one line expected no error
./120++ test/declList_noError.cpp
echo
