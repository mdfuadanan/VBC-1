library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction_Memory_16_Byte is
    port (
        clk     : in std_logic;
        we      : in std_logic;
        pc_addr : in std_logic_vector(3 downto 0);
        inst    : in std_logic_vector(7 downto 0);
        ir      : out std_logic_vector(7 downto 0)
    );
end Instruction_Memory_16_Byte;

architecture Behavioral of Instruction_Memory_16_Byte is

    type mem_type is array (0 to 15) of std_logic_vector(7 downto 0);

    signal mem : mem_type := (
        0  =>  "10110000",--B0 IN R1, Data
        1  =>  "11010000",--D0 OUT R1
        2  =>  "00100011",--23 LOADI R0, 3
        3  =>  "11000000",--C0 OUT R0
        4  =>  "00010000",--10 MOV R1 R0
        5  =>  "11000000",--C0 OUT R0
        6  =>  "00100101",--25 LOADI R0, 5
        7  =>  "01010000",--50 ADD R1,R0
        8  =>  "11000000",--C0 OUT R0
        9  =>  "01110011",--73 ADDI R1, 3
        10 => "11010000",--D0 OUT R1
        11 => "10010000",--90 SHIFT R1 R0
        12 => "11010000",--D0 OUT R1
        13 => "11110000",--F0 JNZ 
        14 => "00000000",
        15 => "00000000"
    );

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(pc_addr))) <= inst;
            end if;
        end if;
    end process;

    ir <= mem(to_integer(unsigned(pc_addr)));

end Behavioral;