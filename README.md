# Hoverboard

![Release](https://img.shields.io/github/release/elslooo/hoverboard.svg)
![Downloads](https://img.shields.io/github/downloads/elslooo/hoverboard/total.svg)
![License](https://img.shields.io/github/license/elslooo/hoverboard.svg)


Hoverboard is an intuitive window manager for Mac. With Hoverboard, you only
need to learn 1 shortcut to rearrange your windows in any 2d grid. What makes it
different from countless window managers already available is that Hoverboard is
free, open source and much more intuitive (as shown by empirical alt-research
conducted and peer-reviewed by myself).

![Screencast](Screencast.gif)

If you want to know more about the process of creating this app, consider
[reading my blogpost](https://elsl.ooo/2017/04/16/launching-hoverboard.html).

## Installing

Download the
[latest release](https://github.com/elslooo/hoverboard/releases/latest) from
Github. Open it. When it asks to move to your `/Applications` folder, confirm.
Hoverboard can only update if it's in `/Applications` (but it will still ask for
confirmation of course). That's it.

## Getting Started

Hoverboard comes with a brief tour that guides you through the features that it
provides. Still, here is a short summary:

1.  Quickly press and release any of the two `cmd` keys on your keyboard
    (adjacent to your space bar).
2.  Move your windows with your arrow keys. By default it starts with a 1x1
    grid. As soon as you press one of the arrow keys, it expands in that
    direction and resizes the window to half of your grid.
3.  Use `shift` if you want to resize a window to twice the size of a row or
    column.

## Contributing

I am planning to continue the development of Hoverboard. If you spot a bug and
know how to fix it, please feel free to send me a pull request! If you don't
know how to fix it, [send me an email](https://elsl.ooo/about/) and I'll look
into it. In general, I am a bit cautious to add new features ([read
more](https://elsl.ooo/2017/04/16/launching-hoverboard.html)).

### Requirements

-   [Cocoapods](https://cocoapods.org/) to install the dependencies below.
-   [HockeyApp](https://hockeyapp.net/) for crash report collection and
    statistics.
-   [LetsMove](https://github.com/potionfactory/LetsMove) to prompt the user to
    move Hoverboard to the Applications folder (this is necessary for installing
    updates automatically after user confirmation).
-   [Sparkle](https://sparkle-project.org/) is used for updating the app.

Furthermore, it uses some of my own frameworks:

-   ElsloooKit is proprietary and only used for the About window. Replace it by
    Apple's default about window if you decide to fork this project.
-   OnboardKit is used for the Getting Started tour. It's developed with
    Hoverboard in mind and may be a bit oriented very much towards Hoverboard
    but it should be possible to decouple it.

### License

> Copyright 2017 Tim van Elsloo
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

---

Thank you!
