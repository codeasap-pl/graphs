#!/usr/bin/env python3
# -*- coding: utf-8; -*-

import colored
import time

_C = colored


class C:
    # works for me. (TERM=xterm-256color)
    CLEAR_SCREEN = (lambda *args: print("\x1bc"))

    COORD = (lambda s: "%s%s%s" % (
        _C.fore.BLUE, s, _C.style.RESET))
    BLANK = (lambda s: "%s%s%s%s" % (
        _C.back.BLACK, _C.fore.BLUE, s, _C.style.RESET))
    WHITE = (lambda s: "%s%s%s%s" % (
        _C.back.WHITE, _C.fore.BLACK, s, _C.style.RESET))
    BLACK = (lambda s: "%s%s%s%s" % (
        _C.back.BLACK, _C.fore.WHITE, s, _C.style.RESET))
    RED = (lambda s: "%s%s%s%s" % (
        _C.back.RED, _C.fore.WHITE, s, _C.style.RESET))
    GREEN = (lambda s: "%s%s%s%s" % (
        _C.back.GREEN, _C.fore.WHITE, s, _C.style.RESET))
    BLUE = (lambda s: "%s%s%s%s" % (
        _C.back.BLUE, _C.fore.WHITE, s, _C.style.RESET))
    GRAY = (lambda s: "%s%s%s%s" % (
        _C.back.LIGHT_GRAY, _C.fore.BLACK, s, _C.style.RESET))


class Field:
    def __init__(self, coords, value, color=C.BLANK):
        self.coords = coords
        self.value = value
        self.color = color

    def __str__(self):
        return str(self.value)


class Board:
    C = C

    def __init__(self, rows=8, cols=8, *fields, **kwargs):
        self.rlim = rows
        self.clim = cols
        self.csym = [str(n) for n in range(0, self.clim)]
        self.rsym = [str(n) for n in range(0, self.rlim)]
        self.fields = []
        self.field_map = {}
        self.reset()

    def reset(self):
        self.fields = [
            [Field([r, c], "-") for c in range(self.clim)]
            for r in range(self.rlim)
        ]

    def redraw(self, /, clear=True, delay=0):
        time.sleep(delay) if delay else ...
        C.CLEAR_SCREEN() if clear else ...
        # COORDS
        print("".center(4), end="")
        for c in range(self.clim):
            print(C.COORD(self.csym[c].center(4)), end="")
        print()

        for r in range(self.rlim):
            print(C.COORD(self.rsym[r].center(4)), end="")
            for c in range(self.clim):
                field = self.fields[r][c]
                print(field.color(str(field).center(4)), end="")
            print()

        # COORDS
        print("".center(4), end="")
        for c in range(self.clim):
            print(C.COORD(self.csym[c].center(4)), end="")
        print()

    def set_field(self, r, c, color=C.GREEN, value="*", /, field_id=""):
        print("R", r, "C", c)
        field = Field([r, c], value, color)
        self.fields[r][c] = field
        if field_id:
            self.field_map[field_id] = field

    def clear_field(self, r, c):
        self.fields[r][c] = Field([r, c], "")

    def draw_edge(self, src, dst, color=C.GREEN, /, clear=True, delay=0):
        sr, sc = self.field_map[src].coords
        dr, dc = self.field_map[dst].coords

        cols = []
        rows = []

        if sr == dr:
            rows = [sr] * abs(sc - dc)
        else:
            rows = list(range(min(sr, dr) + 1, max(sr, dr)))

        if sc == dc:
            cols = [sc] * abs(sr - dr)
        else:
            cols = list(range(min(sc, dc) + 1, max(sc, dc)))

        # sorry, fix me if you can. :-)
        # print(f"sr: {sr}, sc: {sc}, dr: {dr}, dc: {dc}")
        if sr > dr and sc < dc:
            rows.reverse()
        if sr < dr and sc > dc:
            cols.reverse()

        pairs = zip(rows, cols)
        for coords in pairs:
            self.set_field(*coords, color)
            self.redraw(clear, delay)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--cols", type=int, default=8)
    parser.add_argument("-r", "--rows", type=int, default=8)

    args = parser.parse_args()
    board = Board(args.rows, args.cols)
    board.set_field(1, 1)
    board.redraw()
