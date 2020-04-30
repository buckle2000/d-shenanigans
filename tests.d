module tests;
import std.stdio;

// interface Control
// {
// }

// class Window : Control
// {
//     private Control child;
//     this(Control _child)
//     {
//         writeln("new Window");
//         child = _child;
//     }
// }

// class VBox : Control
// {
//     private Control[] children;
//     this(Control[] _children)
//     {
//         writeln("new VBox");
//         children = _children;
//     }
// }

// void dsltest()
// {
//     auto window = new Window(new VBox([]));
// }


struct Nothin {}

class Nil {}
class One {}

void casttest() {
    // auto a = cast(Nothin) 1;
    if (auto a = cast(Nil) new One()) {
        writeln(a);
    } else {
        writeln("Cast failed");
    }
    int x;
    auto x = cast(const) x;
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
        this(ref R _inner)
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

import std.concurrency;
import core.thread;
import core.atomic;

void inc_i(shared int* i, shared bool* done)
{
    // you can write `!done` here and no error in the compiler
    bad D
    while (!*done)
    {
        atomicOp!"+="(*i, 1);
        Thread.sleep(1.seconds);
    }
}

void sharedmemorytest()
{
    shared int i = 0;
    shared bool done = false;
    spawn(&inc_i, &i, &done);
    5.iota.each!((_) { writeln(i); Thread.sleep(1.seconds); });
    writeln("hi");
    // no way to terminate another thread without sending SIGINT to this process
    done = true;
}

import std.variant;

alias Action = Algebraic!(AttackAction, MoveAction);

struct AttackAction
{
    int damage;
}

struct MoveAction
{
    Vector2 direction;
    alias direction this;
}

void varianttest()
{
    Action[] actions;
    actions ~= cast(Action) MoveAction(Vector2(1, 1));
    actions ~= cast(Action) AttackAction(10);
    actions ~= cast(Action) AttackAction(90);
    actions ~= cast(Action) MoveAction(Vector2(0, 100));
    foreach (a; actions)
    {
        auto result = a.visit!(
            (AttackAction a) => {writefln("This is an AttackAction damage=%s", a.damage); return 2;},
            (MoveAction a) {writefln("This is a MoveAction: %s, %s", a.x, a.y); return 1;},
        );
    }

    // final switch()
}

struct Vector2
{
    int x;
    int y;
}

interface Common
{
    @property int zero();
}

import std.typecons;

struct CommonA
{
CommonC c;

}

struct CommonB
{

}

class CommonC
{
    int a=3;
}

void struct_interface_test()
{
    // Common[] commons;
    // commons ~= CommonA();
auto a = CommonA();
scope auto c = CommonC();
writeln(a.c);
writeln(c);
writeln(&a);
writeln(&c);
}

void arraytest3()
{
    immutable auto a = [1,2,3];
    auto b = a; // same array
    // b[2] = 0; // error
    auto c = a.dup;
    c[2] = 0;
    writeln(&a, a);
    writeln(&b, b);
    writeln(&c, c);
}

void remove_foreach_test()
{
    import std.algorithm: remove, SwapStrategy;

    auto a = [2, 3, 4, 5, 6, 7, 8, 9, 10];
    foreach (i, v; a)
    {
        if (v % 2 == 0)
            a = a.remove!(SwapStrategy.unstable)(i);
    writeln(a);
    }
}

immutable auto a = [1, 2, 3, 4, 5];
immutable int[int] b;

shared static this()
{
    b = [2: 3];
}

struct C
{
    int field = 9;
}

void immutabletest()
{
    C c = C(0);
    writeln(c);
    // destroy(c);
    c = c.init;
    
    writeln(c);
    writeln(typeid(a));
    writeln(typeid(b));

}

void scopetest()
{
    writeln(1);
    scope(exit) writeln(2);
    scope(exit) writeln(3);
    return;
    scope(exit) writeln(5); // not eagerly evaluated
}

struct A
{
    int member = 5;
}

void withtest(A a)
{
    with (a)
    {
        writeln(member);
    }
}

void sigsegvtest()
{
    char[] arr = cast(char[])"Hello World.";
    arr[0] = ' '; // SIGSEGV
}

void contracttest()
{
    void lessthan2(int a)
    in
    {
        assert(a < 2);
    }
    do
    {
        writeln(a);
    }

    lessthan2(1);
    lessthan2(3);
}

void ctfetest()
{
    // this thing is so slow to compile
    import std.regex;
    immutable auto ctr = ctRegex!(`^.*/([^/]+)/?$`);
    writeln("".match(ctr));
    writeln("..".match(ctr));
    writeln(".".match(ctr));
    writeln("/".match(ctr));
    writeln("/home/user".match(ctr));
    writeln("/home/user/Downloads/".match(ctr));
    writeln("/home/user/Downloads".match(ctr));
}

void rangetest2()
{
    import std.algorithm;

    [1, 2, 3].each!(writeln);
    [1, 2, 3].each!(a => writeln(a));
    [1, 2, 3].each!((a) => writeln(a));
    [1, 2, 3].each!((a) { return writeln(a); });

    // [1,2,3].sort;
}

void multiplereturntest()
{
    void hello(int a, int b, ref int c, ref int d)
    {
        c = a;
        d = b;
    }

    int a = 1, b = 2;
    int c, d;
    hello(a, b, c, d);
    writefln("%s %s", c, d);

    import std.typecons : tuple;

    auto t = tuple(1, "a");
}

void hashtest()
{
    char[][string] arr;
    // keys must be immutable
    // arr[['h', 'i']] = 10;
    // char[] value = cast(char[])"world"; // write to immutable data -> SIGSEGV
    char[] value = ['w', 'o', 'r', 'l', 'd'];
    arr["hello"] = value;
    writeln(arr);
    value[0] = 'W';
    writeln(arr);
    writeln("hewwo?");

    import std.algorithm;
    import std.array;

    auto array = ['a', 'a', 'a', 'b', 'b', 'c', 'd', 'e', 'e'];

    // `.group` groups consecutively equivalent
    // elements into a single tuple of the
    // element and the number of its repetitions
    auto keyValue = array.group;
    writeln("Key/Value range: ", keyValue);
    writeln("Associative array: ", keyValue.assocArray);
}

void rangetest()
{
    import std.range;
    import std.algorithm;

    writeln(5.iota); // lazy
    writeln(5.iota.take(3)); // lazy
    writeln(42.repeat.take(3)); // lazy
    writeln(5.iota[1]); // random access
    writeln(5.iota.retro[1]); // bidirectional & random access
    writeln(FibonacciRange().take(5).map!(x => -x)
            .array
            .sort!((a, b) => a < b));
}

struct FibonacciRange
{
    // States of the Fibonacci generator
    int a = 1, b = 1;
    // The fibonacci range never ends
    enum empty = false;
    // Peek at the first element
    int front() const @property
    {
        return a;
    }
    // Remove the first element
    void popFront()
    {
        auto t = a;
        a = b;
        b = t + b;
    }
}

void looptest()
{
    int[5] arr;
    foreach (int i, ref e; arr)
    {
        e = 3 * i;
    }
    foreach (el; arr)
    {
        writef("%s ", el);
    }
    writeln();
}

void stringtest()
{
    import std.array : array;
    import std.conv : to;
    import std.range : walkLength;
    import std.uni : byGrapheme;

    string s = "你好";

    writeln(s.length); // 3
    writeln(s.walkLength); // 2
    writeln(s.byGrapheme.walkLength); // 1

    writeln(s.length); // ??
    foreach (i; s)
    {
        writeln('\t', i);
    }
    writeln(s.array.length);
    // auto decoding when iterating
    foreach (dchar i; s)
    {
        writeln('\t', i);
    }
    // dstring
    writeln(s.to!dstring[0]);
}

struct Vector3
{
    double x;
    double y;
    double z;
}

double dot(ref Vector3 lhs, ref Vector3 rhs)
{
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
}

void structtest()
{
    writeln("Structure test");
    auto vec1 = Vector3(10, 0, 0);
    Vector3 vec2;
    vec2.x = 0;
    vec2.y = 20;
    vec2.z = 0;

    // Test the functionality for dot product
    assert(dot(vec1, vec2) == 0);
    assert(vec1.dot(vec2) == 0);
}

void arraytest()
{
    int[] arr = [1, 2, 3, 4, 5];
    writeln(arr);
    arr[] *= 2;
    writeln(arr);
    arr[] = 0;
    // syntax error
    // arr = 0;
    writeln(arr);

    int[3] arr2 = 8;
    writeln(arr2);

    int[3] arr3;
    writeln(arr3);
    arr3 = 5;
    writeln(arr3);
    arr3[] = 4;
    writeln(arr3);
    auto arr4 = arr3 ~ arr2;
    writeln(arr4);

    // char[] works too
    char[] message = [
        'w', 'e', 'l', 'c', 'o', 'm', 'e', 't', 'o', 'd',
        // The last , is okay and will just
        // be ignored!
    ];
    writeln("Before: ", message);
    message[] = (message[] - ('w' - 'm') - 'a' + 26) % 26 + 'a';
    writeln("After:     ", message);
    writeln("Should be: ", ['m', 'u', 'b', 's', 'e', 'c', 'u', 'j', 'e', 't']);
}

void arraytest2()
{
    int[] arr = [0, 1, 2, 3, 4];
    writeln(arr.length);
    writeln(arr[$ - 1]);
    writeln(arr[$ - 3]);
    writeln(arr[0 .. 2]);
    writeln(arr[0 .. $]);
    // writeln(arr.length);
    arr[1 .. 3] *= 10;
    writeln(arr[]);
}