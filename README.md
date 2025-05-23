# ![](img/rt.png) Rad-Therapy (FreeHL)

This is a port of the 1998 game 'Half-Life' to Quake(World). Powered by Nuclide and the [FTE Engine](https://www.fteqw.org/).

![Preview 1](img/preview1.jpg)
![Preview 2](img/preview2.jpg)
![Preview 3](img/preview3.jpg)
![Preview 4](img/preview4.jpg)

## Installing/Running

To run it, all you need is [FTE](https://www.fteqw.org) and [the latest release .pk3 file](https://www.frag-net.com/pkgs/package_valve.pk3), which you save into `Half-Life/valve/`. 

**That's about it.**

You can install updates through the **Configuration > Updates** menu.

As this is Quake, there is no native game code. This is CPU architecture independent.
You only need to build from source if you plan on making changes.

## Building from Source

Clone the repository into the [Nuclide-SDK](https://code.idtech.space/vera/nuclide) and build it like so:

```
$ cd nuclide
$ git clone https://code.idtech.space/fn/valve valve
$ make game GAME=valve
```

## Notes

The engine should automatically detect Half-Life when placed within the game directory, however you may need to pass `-halflife` just in case you have one massive directory with multiple FTE-supported games in it for example.

You can also launch mods like this: `fteqw -halflife -game cstrike`

## Community

### Matrix
If you're a fellow Matrix user, join the Nuclide Space to see live-updates and more!
https://matrix.to/#/#nuclide:matrix.org

### IRC
Join us on #freecs via irc.libera.chat and talk/lurk or discuss bugs, issues
and other such things. It's bridged with the Matrix room of the same name!

### Others
We've had people ask in the oddest of places for help, please don't do that.

## Special Thanks

- Spike for FTEQW and for being the most helpful person all around!
- Xylemon for the hundreds of test maps, verifying entity and game-logic behaviour
- Theuaredead`, preston22, dqus for various patches
- To my supporters on Patreon, who are always eager to follow what I do.
- Any and all people trying it, tinkering with it etc. :)

## License
ISC License

Copyright (c) 2016-2025 Marco "eukara" Cawthorne <marco@icculus.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
