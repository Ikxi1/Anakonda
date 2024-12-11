# Anakonda

Building / Assembling on Linux <br/>
``nasm -felf64 parser.asm && ld -o Anakonda parser.o``

Run <br/>
``./Anakonda test.py``

This is intended for x86_64 machines running Linux. <br/>
Though I also got it to run via qemu-user-x86_64 on my Android phone in Termux.

You can use any .py python file. <br/>
Though at the moment only printing strings is suuported ``print("Anakonda")``-
