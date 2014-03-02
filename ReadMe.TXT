
            SGPMIX (Mixer for Sound Galaxy Pro16 Extra) by Doodle
            -----------------------------------------------------


Description:

  This is a Mixer program that can be used to set the main settings of a
  Sound Galaxy Pro16 Extra. I've created it for myself, because I could
  not find a mixer which could be used with my card, and could set all the
  settings I wanted.


Usage:

  The program itself is SGPMIX.EXE. Nothing special is needed, simply copy
  it into a directory and run it.


Sources/Compilation:

  All the sources are included. To compile it, you will need the followings:
   - IBM OS/2 DEVELOPER'S TOOLKIT (Included with eComStation)
   - Virtual Pascal v2.1 (can be freely downloaded from www.vpascal.com)

  To create an EXE, you will have to take care of the followings:

   - Execute R.CMD, which will create the pascal-style resource file and
     include file from the dialog.dlg and dialog.h files.

   - Make sure that the INCLUDE environment variable contains the path to
     the header files of the toolkit. (In my case, SET INCLUDE=F:\os2tk45\h) 
     They are needed to compile the resources.

   - Start Virtual Pascal, change its directory to the directory of sgpmix.pas
     (File->Change Dir...)

   - Open the sgpmix.pas file

   - Build it! (Compile->Build)


Changing the sources:

  You are allowed to do changes, and do everything you want with the program
  and/or the sources.

  To change the window of the program use the DLGEDIT.EXE from the toolkit to 
  edit the dialog.res file. It will also modify the dialog.dlg and dialog.h
  files. Run R.CMD to reflect the changes to pascal.

  It's easy to create your own mixer for your sound card, if you know some
  internals of your card. All you have to do is to clone the SGP16EMX.PAS file.


Contact information:

  I don't plan to do changes to this program, anyway, the sourcecode is open,
  so anybody can change it. :) The purpose of the release is to help others
  with creating OS/2 applications.

  If you still want to contact me, send an e-mail to 
  Doodle <kocsisp@dragon.klte.hu>
