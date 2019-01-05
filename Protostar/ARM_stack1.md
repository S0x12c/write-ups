# Protostar ARM stack1 write-up

I downloaded Protostar Stack Overflow challenges compiled for ARM from [Azeria Labs' GitHub](https://github.com/azeria-labs/ARM-challenges).

### Finding starting point

I like to start from running the binary to see how it behaves - we can see that the binary expects an argument.
![alt text](img/ARM_stack1_01.png)

I ran the binary in gdb with GEF and disassembled main function.
![alt text](img/ARM_stack1_02.png)

From the screenshot above we can see two interesting functions - errx and strcpy. Errx if probably related to checking if arguments were given. We can confirm this by setting breakpoint on errx function (`b \*0x000104d8`) and running the next instruction (`nexti`).
![alt text](img/ARM_stack1_03.png)

The second function is strcpy which has the potential to be vulnerable to buffer overflow.

So I removed existing breakpoint (in my case `del 1`) and put new breakpoint on the strcpy function by typing `b \*0x000104fc` and ran the program with an argument `run asdf`.
![alt text](img/ARM_stack1_04.png)

We can see that our argument is now in registers r2 and r3. To observe how the binary works I ran `nexti` to step to the next instruction.
After strcpy function we can see that the value from the address r11 with offset -8 is going to be loaded into register r3 and the value from the pc registry with an offset 48 will be loaded into register r2. The next instruction compares values of both registers.
Right now, the register r3 holds value 0x0 and register r2 0x61626364.
![alt text](img/ARM_stack1_05.png)

After running a few more instructions, we get a message "Try again, you got 0x%08x".

Therefore we can conclude that we need to do something to put the same value into register r3 as in register r2.
So we run the binary again with longer argument.

After loading value to the r3 we can see that it has a part of our argument - 0x73616664 ("dfas"?).

And we can now see that the r2 and r3 registries are somehow similar.
![alt text](img/ARM_stack1_06.png)

Which takes us a little closer but it still not the same. After running another few instructions we again get "Try again, you got 0x%08x".

Ok, so evidently we have to put the value dcba or in hex (0x61626364) into register r3.

To find exact place we will use python script that will create our pattern and then calculate the offset [pattern\_tools](https://github.com/jbertman/pattern_tools).

With the script inside our current directory we run python and we call pattern\_create function to create pattern with 256 characters.
![alt text](img/ARM_stack1_07.png)

We then put breakpoint on `cmp r3, r2` instruction with `b \*0x00010508`, copy the created pattern and suply this into our binary in gdb.
![alt text](img/ARM_stack1_08.png)

We can see that r3 register has now 0x63413163 ("c1Ac"?) value.
We copy the address from r3 registry and run the following function in python.
![alt text](img/ARM_stack1_09.png)


We got the information that the offset is 64, so now we know, that after 64 characters we override the r3 address.

We run:
![alt text](img/ARM_stack1_10.png)

and run the binary within gdb with argument AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdcba
![alt text](img/ARM_stack1_11.png)

and we can see that our r3 is now equal to r2, after few 'nexti' we get the message "you have correctly got the variable to the right value".


Different way to run this binary is by using the following commands:

`$ python -c "print 64 * 'A' + r'\x64\x63\x62\x61'"`
![alt text](img/ARM_stack1_12.png)


the hex value is fipped because of little endian architecture??

`$ printf "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x64\x63\x62\x61" | xargs ./stack1`




