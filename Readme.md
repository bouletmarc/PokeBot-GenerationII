# PokéBot Generation II

An automated computer program that speedruns Pokémon Cristal (gold/silver not made yet).

### Run the bot locally

Running the PokéBot on your own machine is easy. You will need a Windows environment (it runs great in VMs on Mac/Linux too).

1. First, clone this repository (or download and unzip it) to your computer.

2. Download the [BizHawk 1.6.1](http://sourceforge.net/projects/bizhawk/files/BizHawk/BizHawk-1.6.1.zip/download) emulator and extract the ZIP file anywhere you like to “install” it.

    **Note:** BizHawk v1.6.1 (Windows only) is the only version known to work. Later versions like v1.7.2a do not seem to work, due to differences with reading bytes from memory.

3. Run [the BizHawk prerequisites installer](http://sourceforge.net/projects/bizhawk/files/Prerequisites/bizhawk_prereqs_v1.1.zip/download), which should update a C++ distributable needed by BizHawk.

4. Procure a ROM file of Pokémon Crystal (not yet for gold/silver) english version (japan might not work and you should personally own the game).

5. Open the ROM file with BizHawk (drag the `.gb` file onto EmuHawk), and Pokémon should start up. Otherwise select Open ROM in EmuHawk.

6. The colors may look weird. To fix this, go to _GB_ → _Palette Editor_, and then find the `POKEMON ***.pal` file which should be under _Gameboy_ → _Palettes_ in the directory where BizHawk was extracted.

7. If you want to test the full run, set [`RESET_FOR_TIME` in `main.lua`](https://github.com/kylecoburn/PokeBot/blob/0fd1258ca17f7d74edbac72fa0afc2b5c6d58bb3/main.lua#L3) to `false` instead of `true`.

8. Then, under the _Tools_ menu, select _Lua Console_. Click the “open folder” button, and navigate to the PokéBot folder you downloaded. Select `main.lua` and press “open”. The bot should start running!

## Seeds

PokéBot comes with a built-in run recording feature that takes advantage of random number seeding to reproduce runs in their entirety. Any time the bot resets or beats the game, it will log a number to the Lua console that is the seed for the run. If you set `CUSTOM_SEED` in `main.lua` to that number, the bot will reproduce your run, allowing you to [share your times with others](Seeds.md). Note that making any other modifications will prevent this from working. So if you want to make changes to the bot and share your time, be sure to fork the repo and push your changes.

## Credits

### Developers

Kyle Coburn: Original concept

Michael Jondahl: Combat algorithm, Java bridge for connecting the bot to Twitch chat, LiveSplit, Twitter, etc.

Marc-Andre Boulet(Bouletmarc): PokeBot GenerationII

### Special thanks

To LiveSplit for providing custom component for integrating in-game time splits.

To the Pokémon speedrunning community members who inspired the idea, and shared ways to improve the bot.