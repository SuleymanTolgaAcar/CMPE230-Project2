# CMPE 230 Project 2 - Postfix to RISC-V Translator

## General Program Flow

The program takes one line of input from the terminal, executes necessary operations, and prints the resulting RISC-V instructions. The input is in postfix format and supports operations: addition, subtraction, multiplication, logic xor, logic and, logic or. Since the input is in postfix format, executing them using a stack-based implementation is simpler. We used assembly’s default stack for this. Then, we converted the resulting numbers to binary representations. Finally, we printed RISC-V instructions accordingly.

## Handling input and executing operations

The program reads from input buffer one character at a time. If that character is a number, it waits for a space, then it converts the number from string to decimal and pushes it onto the stack. To convert the number to decimal, we subtracted 48 from the first character which is the ASCII number for the character ‘0’. Then repeated the process while multiplying the result by 10 for each character. If the current character is an operator, it pops two numbers from the stack, performs the operation and pushes the result onto the stack. Finally, if the character is the new line character, it terminates the program.

## Printing RISC-V Instructions

In order to print the corresponding RISC-V instructions, we converted the numbers from decimal to binary. We achieved this by using logic “and” operation on the number popped from the stack and 1. This gives the least significant bit. Then we shifted the number to right by 1 bit and repeated the process to get the next bit. After converting the number to binary and printing it, we printed remaining parts of the instruction. Since operation instructions are just constant values, printing them was easier.

## Running the program

To run the program, you can use the following commands:

```bash
make
./postfix_translator
```

## Testing

You can test the program with given input and outputs in the "test-cases" folder. You can use the following command to run the tests:

```bash
make grade
```

or one of the following commands depending on your system:

```bash
make
python3 test/grader.py ./postfix_translator test-cases
```

```bash
make
python test/grader.py ./postfix_translator test-cases
```

```bash
make
py test/grader.py ./postfix_translator test-cases
```
