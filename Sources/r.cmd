@echo off

rem This script creates the pascal-compatible RC file and INC file from
rem the dialog.dlg and dialog.h files, that are created by the dialog editor.
rem (dlgedit.exe)

respp dialog
del sgpmix.rc
del sgpmix.inc
rename dialog.plg sgpmix.rc
rename dialog.inc sgpmix.inc
