# Brainfuck-Interpreter
A brainfuck interpreter written in assembly

## Usage
The program takes one (required) argument, a file name to run. The interpreter itself just takes a pointer to a (null-terminated) character array.

## Brainfuck
Brainfuck is an esoteric programming language. It operates on a memory array (by default its length is 30,000 and element size is 1 byte).
It is Turing complete given that it has enough memory to operate on.
It has a few basic instructions:
- `>`	Move the pointer to the right
- `<`	Move the pointer to the left
- `+`	Increment the value at the pointer
- `-`	Decrement the value at the pointer
- `.`	Write the character at the pointer
- `,`	Read a character and store it at the pointer
- `[`	Jump to the character after the matching closing bracket if the value at the pointer is zero
- `]`	Jump to the character after the matching opening bracket if the value at the pointer is nonzero
