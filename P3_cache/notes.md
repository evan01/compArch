# Notes

This is a hopefully useful text file with some useful definitions for this assignment.

#### Block

A 'section' of data from memory

#### Address

The address is broken into 3 parts.
`[TAG | INDEX | OFFSET]`

`TAG` -> A unique identifier for each memory block!  
`INDEX` -> The Cache row/location/array spot where the block goes to  
`OFFSET` -> The position within the block that you want to read from.

#### Write Back Policy
This is a storage method where data is written into the cache every time a
change occurs, but you only write to memory at specific intervals or under certain conditions

#### Direct Mapped
Assigns each block of memory to a specific line in the cache. If a line is already
taken by a memory block when a new one needs to be loaded, the old one is trashed.
The modulus function is usually a good way to do this. If our cache has 32 blocks, with 128 bits each.
We must map each 128 bit block in memory to one of the 32 blocks.

## How Our Specific Cache Works
We will receive as input...

`s_adr[31:0]` - The address in memory that we want to read/write to  
`s_write[31:0]` - If a write operation, then a word to write to memory

Our Cache has 128 bit blocks, -> 7 bits for `OFFSET`.  
We have 32 free/used blocks in the cache at any time -> 5 bits for `INDEX`  
We have 32 bit addresses, so 32-7-5-17 = 3 bits for `TAG`  

## Example
We want to read a 32 bits (1 word from the address below)
`s_adr = [0000 0000 0000 0000 0111 0100 0111 1000]` (32 bit address in binary)

For this assignment, we will never have an address > 2^16 bits (mem constraints in handout)  
Also, for this assignment, we are only reading and writing words (32 bits)  
- This means that the first 17 bits are irrelevant (affects tag, ie: we can now use shorter tag)  
- The last 2 bits are irrelevant. (does not affect offset calculation)


1. Find the `block_offset` = Last 7 bits of address `= 111 1000 (120)`
2. Determine the `Index` of this address. = The next 5 bits! `0100 0 (8)`
3. Remaining bits up to 15th make up the tag `= 111 =(3)` (could have used all remaining bits)

Our Cache Data Structure will look something like this...  
`[ValidBit| DirtyBit | TAG (3 bits) | Index(5 bits) | Offset(7 bits)| DATA (32 bits)]`

After our first read.  
`[1 | 1 | 111 | 01000 | 1111000 | 32 bits of data]`

## Signal Mapping
`clock` -> the clock driving the sync. hardware

`reset` -> when high, cache is emptied, states reset

`s_addr` -> the address we want to read/ write to

`s_read` -> a bit indicating whether to read/write

`s_readdata` -> the data returned by the cache at *s_addr*

`s_writedata` -> the data we are writing to the cache at *s_addr*

`s_waitrequest` -> when high, signals that the cache is busy




