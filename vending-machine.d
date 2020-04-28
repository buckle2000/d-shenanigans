#!/usr/bin/env rdmd
module generic_vending_machine;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.format;
import std.stdio;
import std.string;
import core.thread;

immutable string ver = "1.0.2";
immutable string brand = "Generic™";

struct Product
{
    string id;
    float price;
    string desc;
}

Product[] getProducts(string filename)
{
    return File(filename).byLine
        .map!((line) {
            string id, desc;
            float price;
            line.formattedRead!"%s\t%f\t%s"(id, price, desc);
            return Product(id, price, desc);
        })
        .array
        .sort!((a, b) => a.id < b.id)
        .sort!((a, b) => a.price < b.price)
        .array;
}

void main()
{
// greetings:
    writefln("%s POS SYSTEM VERSION %s", brand.toUpper, ver);
    writefln("Thanks for choosing %s brand vending machine!", brand);
    writeln();

    writeln(">>> Today's stock:");
    const auto products = getProducts("products");
    writefln("%2s - %-30s %s", "№", "Name", "Price");
    foreach (i, p; products)
    {
        writefln("%2s - %-30s %5.2f", i, p.desc, p.price);
    }
    writeln();

    int choice;
    string cardInfo;

pick_item:
    write("Pick an item: ");
    string choiceRaw = readln.strip;
    if (choiceRaw.length == 0)
    {
        writeln("Cancelled.");
        goto goodbye;
    }
    try
    {
        choiceRaw.formattedRead!"%d"(choice);
        enforce!ConvException(choice >= 0, "Number too low");
        enforce!ConvException(choice < products.count, "Number too high");
    }
    catch (ConvException e)
    {
        if (e.message.startsWith("Unexpected"))
        {
            write("You have to enter an integer.");
        }
        else
        {
            write(e.message);
        }
        writeln(" Please try again.");
        goto pick_item;
    }

insert_card:
    writeln("Insert your card to checkout.");
    cardInfo = readln.strip;
    if (cardInfo.length == 0)
    {
        writeln("Cancelled.");
        goto goodbye;
    }
    try
    {
        enforce!ConvException(cardInfo.length == 16, "Card is invalid.");
    }
    catch (ConvException e)
    {
        write(e.message);
        writeln(" Please try again.");
        goto insert_card;
    }

    writeln("Dispensing item, please wait...");
    Thread.sleep(dur!"seconds"(3));

goodbye:
    writeln();
    writefln("Thank you for choosing %s vending machine!", brand);
}
