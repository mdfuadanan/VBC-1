library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.all;

entity VBC1_Top_tb is
end VBC1_Top_tb;

architecture Behavioral of VBC1_Top_tb is

    signal CLK : std_logic := '0';
    signal RST : std_logic := '0';

    signal SW : std_logic_vector(3 downto 0) := "0000";

    signal LED_Op : std_logic_vector(3 downto 0);
    signal LED_IO : std_logic_vector(3 downto 0);

    signal LED : std_logic_vector(7 downto 0);
    signal Seg : std_logic_vector(6 downto 0);

    signal M1,M2,M3,M4,M5,M6 : std_logic;
    signal Load_R0,Load_R1,Load_OP : std_logic;
    signal Z0,Z1 : std_logic;
    signal Load_DR,Load_LED,Load_SEG : std_logic;

    signal IR : std_logic_vector(7 downto 0);
    signal DI,R0,R1,mem_address,Ir_3_to_0 :
        std_logic_vector(3 downto 0);

begin

    DUT : entity work.VBC1_Top
        port map(
            CLK => CLK,
            RST => RST,
            SW => SW,

            LED_Op => LED_Op,
            LED_IO => LED_IO,

            LED => LED,
            Seg => Seg,

            M1 => M1,
            M2 => M2,
            M3 => M3,
            M4 => M4,
            M5 => M5,
            M6 => M6,

            Load_R0 => Load_R0,
            Load_R1 => Load_R1,
            Load_OP => Load_OP,

            Z0 => Z0,
            Z1 => Z1,

            Load_DR => Load_DR,
            Load_LED => Load_LED,
            Load_SEG => Load_SEG,

            IR => IR,

            DI => DI,
            R0 => R0,
            R1 => R1,
            mem_address => mem_address,
            Ir_3_to_0 => Ir_3_to_0
        );

    CLK <= not CLK after 5 ns;

    process
    begin

        RST <= '1';
        SW <= "0000";

        wait for 20 ns;

        RST <= '0';

        wait for 100 ns;

        SW <= "0001";
        wait for 100 ns;

        SW <= "0010";
        wait for 100 ns;

        SW <= "0011";
        wait for 100 ns;

        SW <= "0100";
        wait for 100 ns;

        SW <= "0101";
        wait for 100 ns;

        SW <= "0110";
        wait for 100 ns;

        SW <= "0111";
        wait for 100 ns;

        SW <= "1111";
        wait for 100 ns;

        report "Simulation finished" severity note;
        stop;

    end process;

end Behavioral;