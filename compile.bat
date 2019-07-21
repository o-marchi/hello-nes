del main.o
del main.nes

ca65 main.asm -o main.o -t nes --debug-info
ld65 main.o -o main.nes -t nes

:: ----------------------------------------
:: Configure your emulator below
:: ----------------------------------------

:: if exist main.nes (
:: 	fceux\fceux.exe main.nes
:: )