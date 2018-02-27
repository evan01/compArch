library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity read_controller is
    generic( ram_size : INTEGER := 32768);
    port(
    clock : in std_logic;
    reset : in std_logic;
    s_addr: in std_logic_vector(31 downto 0);
    s_read : in std_logic;
	s_readdata : out std_logic_vector(31 downto 0);
    s_waitrequest : out std_logic;
    cache_array: inout cache_type;
    --"internal" signals interfacing with mem_controller
    mem_controller_data: inout std_logic_vector(127 downto 0);
    mem_controller_addr: out std_logic_vector(14 downto 0);
    mem_controller_read : out std_logic;
    mem_controller_write: out std_logic;
    mem_controller_wait: in std_logic
);
end read_controller;

ARCHITECTURE arch OF read_controller IS
--TYPE CACHE IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
--TYPE CACHE IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(135 DOWNTO 0);
--signal cache_array: CACHE;
type  read_states is (I, R, MR, MW, RP, D);  -- Define the states
signal state: read_states;

signal tag: std_logic_vector(5 downto 0); --remaining bits up to 15th
signal index: std_logic_vector(4 downto 0); --next 5 bits
signal offset: std_logic_vector(1 downto 0); --Last 4 bits of address - 2 last
signal cache_block: std_logic_vector(135 downto 0);


signal valid: std_logic;
signal dirty: std_logic;

BEGIN

read_fsm : process(clock, reset)

variable int_offset: integer;
BEGIN
    if (reset ='1') then
        state <= I;
    elsif (rising_edge(clock)) then
        case state is
            when I =>
                if (s_read = '1') then             
                    state <= R;
                     s_waitrequest <= '1';
                else
                     s_waitrequest <= '0';
                end if;
                mem_controller_addr <= (others => '-');
               
            when R =>
          
                offset <= s_addr(3 downto 2); 
                index <= s_addr(8 downto 4); 
                tag <= s_addr(14 downto 9);

                cache_block <= cache_array(to_integer(unsigned(index)));

                valid <= cache_block(135); 
                dirty <= cache_block(134);

                --check validity
                if(valid = '1') then
                    --check for cache hit
                    if (cache_block(133 downto 128) = tag) then
                        --Hit
                        state <= D;
                    else
                        --Miss
                        --if dirty, write cache block to mem then fetch block from memory
                        if (dirty = '1') then
                            state <= MW;
                        else
                        --if clean, directly fetch from memory
                            state <= MR;
                        end if;
                    end if;
                else
                    --if invalid, then fetch block from memory
                    state <= MR;
                end if;
            when D =>
                --when done, load cache_block into readdata output

                int_offset := to_integer(unsigned(offset));
                s_readdata <= cache_block(31+int_offset*32 downto 0 + 32*int_offset);
                s_waitrequest <= '0';
                state <= I;
            when MW =>
                --if write to mem is needed, set m_write and put data on m_writedata

                mem_controller_write <= '1';
                mem_controller_read <= '0';
                mem_controller_data <= cache_block(127 downto 0);
                mem_controller_addr(14 downto 9) <= cache_block(133 downto 128);
                mem_controller_addr(8 downto 4) <= index;


                --wait for mem_controller to have written
                if (mem_controller_wait = '1') then
                    state <= MW;
                else
                    --write is done
                    mem_controller_write <= '0';
                    cache_block(134) <= '0'; --reset dirty bit
                    state <= MR;
                end if;
            when MR =>
                --if read from mem is necessary, set m_read
                mem_controller_read <= '1';
                mem_controller_write <= '0';

                --wait for mem_controller
                if (mem_controller_wait = '1') then
                    state <= MR;
                else
                    --put data read from mem into cache_block
                    mem_controller_read <= '0';
                    cache_block(127 downto 0) <= mem_controller_data;
                    state <= RP;
                end if;
            --replace cache_block into cache_array
            when RP =>
                --set valid bit
                cache_block(135) <= '1';
                --cache block is now clean
                cache_block(134) <= '0';
                cache_block(133 downto 128) <= tag;
                --put new block into array
                cache_array(to_integer(unsigned(index))) <= cache_block;
                state <= D;
        end case;
    end if;
END process read_fsm;

END arch;
