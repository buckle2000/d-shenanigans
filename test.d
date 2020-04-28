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
    ducktypingtest2;
    writeln("Program successfully exited.");
}

void ducktypingtest()
{
    void useRange(InputRange!int range)
    {
        // Function body.
    }

    // Create a range type.
    auto squares = map!"a * a"(iota(10));

    // Wrap it in an interface.
    auto squaresWrapped = inputRangeObject(squares);

    // Use it.
    useRange(squaresWrapped);
}

interface Animal
{
    void voice();
}

class Bee : Animal
{
    void voice()
    {
        writeln("Bzzzz");
    }
}

struct Clock
{
    int time;
    void voice()
    {
        writefln("The time is %02d:00", time);
    }
}

struct Rock
{
}

import std.traits : ReturnType;

Animal toAnimal(R)(R r)
{
    class AnimalR : Animal
    {
        R inner;
        this(R _inner)
        {
            inner = _inner;
        }

        static if (is(ReturnType!((R r) => r.voice) == void))
        {
            void voice()
            {
                inner.voice;
            }
        }
        else
        {
            void voice()
            {
                writefln("I'm a %s. I can't speak.", typeid(R).name);
            }
        }
    }

    return new AnimalR(r);
}

void ducktypingtest2()
{
    Animal[] animals;
    animals ~= new Bee();
    animals ~= Clock(7).toAnimal;
    animals ~= Rock().toAnimal;
    writeln(animals);
    foreach (animal; animals)
    {
        writef("%s ", typeid(animal));
        animal.voice();
    }
}
