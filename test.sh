#!/bin/bash
echo Redeclaration: Expecting one error
./120++ test/reDecl.cpp
echo $?
echo
echo Scope nesting: Expecting one error on int rip
./120++ test/nestedDecl.cpp
echo $?
echo
echo Single Declaration: expecting one error on hi
./120++ test/singleDecl.cpp
echo $?
echo
echo syntax error test: expected one error
./120++ test/syntaxError.cpp
echo $?
echo
echo Multiple decls on one line expected no error
./120++ test/declList_noError.cpp
echo $?
echo
echo Addition, one success and one fail
./120++ test/addition.cpp
echo $?
echo
echo Subtraction, one success and one fail
./120++ test/subtraction.cpp
echo $?
echo
echo Multplication, one success and one fail
./120++ test/multiplication.cpp
echo $?
echo
echo Division, one success and one fail
./120++ test/division.cpp
echo $?
echo
echo Assignment one success and one fail
./120++ test/assignment.cpp
echo $?
echo
echo Literals two successes
./120++ test/literals.cpp
echo $?
echo
echo Literals five fails
./120++ test/literalsFail.cpp
echo $?
echo
echo Boolean operators 4 fails
./120++ test/booleanOperatorsFail.cpp
echo $?
echo
echo Boolean operators no fails
./120++ test/booleanOperators.cpp
echo $?
echo
echo Multiple files 2 fails
./120++ test/addition.cpp test/subtraction.cpp
echo $?
echo
echo File does not exist
./120++ fakefile
echo $?
echo
