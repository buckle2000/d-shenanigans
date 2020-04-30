#!/usr/bin/env -S rdmd -g
module test;

import std.stdio;
import std.format;
import std.range;
import std.algorithm;

// import tests;

void main()
{
    // structtest;
    // arraytest;
    // arraytest2;
    // stringtest;
    // looptest;
    // rangetest;
    // hashtest;
    // multiplereturntest;
    // rangetest2;
    // ctfetest;
    // contracttest;
    // sigsegvtest;
    // withtest(A());
    // scopetest;
    // sometest;
    // immutabletest;
    // remove_foreach_test;
    // arraytest3;
    // struct_interface_test;
    // varianttest;
    // polymorphism;
    // sharedmemorytest;
    // ducktypingtest;
    // ducktypingtest2;
    // casttest;
    // dsltest;
    dispatchtest;
    writeln("Program successfully exited.");
}

struct Meh
{
    int x;
}

Meh opUnary(string s)(Meh that)if (s == "-")
{
    return Meh( - that.x);
}

void dispatchtest()
{
    auto foo = Meh(5);
    writeln(-foo); // cannot overload operator without struct method
}
