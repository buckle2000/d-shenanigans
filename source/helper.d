module helper;
import std.traits : isSomeString;

/**
* Reads formatted data from `stdin` using $(REF formattedRead, std,_format).
* Contrary to $(REF readf, std,_stdio), it always consumes a line, even if it fails. 
*/
uint readfln(alias format, S = string, Data...)(auto ref Data data, dchar terminator = '\n')
        if (isSomeString!S && isSomeString!(typeof(format)))
{
    import std.stdio : readln;
    import std.format : formattedRead;

    // TODO: cannot import std.format.checkFormatException
    // Need to find a way to force the check
    const S line = readln!S(terminator = terminator);
    return formattedRead(format, line, data);
}

/**
* Is this ASCII character invisible?
*/
bool isControlCharacter(char c)
{
    return ('\x00' <= c && c <= '\x1F') || ('\x7F' <= c && c <= '\x9F');
}

/**
* Returns the escaped representation of s
*/
string repr(string s)
{
    import std.exception : assumeUnique;
    import std.format : format;

    char[] p;
    for (size_t i; i < s.length; i++)
    {
        switch (s[i])
        {
        case '\'':
        case '\"':
        case '\?':
        case '\\':
            p ~= "\\";
            p ~= s[i];
            break;
        case '\a':
            p ~= "\\a";
            break;
        case '\b':
            p ~= "\\b";
            break;
        case '\f':
            p ~= "\\f";
            break;
        case '\n':
            p ~= "\\n";
            break;
        case '\r':
            p ~= "\\r";
            break;
        case '\t':
            p ~= "\\t";
            break;
        case '\v':
            p ~= "\\v";
            break;
        default:
            if (isControlCharacter(s[i]))
                p ~= format!"\\x%02x"(s[i]);
            else
                p ~= s[i];
            break;
        }
    }
    return assumeUnique(p);
}

version (unittest) import fluent.asserts;

unittest
{
    import std.stdio;

    Assert.equal(repr("sad\\fhl\vsad\fifd\aau\tofa\vdh\x03s\x7fa"),
            r"sad\\fhl\vsad\fifd\aau\tofa\vdh\x03s\x7fa");
}
