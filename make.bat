
@echo off

if "%1" == "" (
  fennel --compile fnl\neovcs\init.fnl > lua\neovcs\init.lua
)

if "%1" == "help" (
    echo Makefile for Windows =)
)

