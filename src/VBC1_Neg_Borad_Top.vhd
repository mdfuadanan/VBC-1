library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VBC1_Board_Top is
    port(
        CLK, CLK_Nano : in  std_logic;
        RST : in  std_logic;
        SW  : in  std_logic_vector(3 downto 0);
        LED : out std_logic_vector(7 downto 0);
        Seg : out std_logic_vector(6 downto 0)
    );
end VBC1_Board_Top;

architecture Behavioral of VBC1_Board_Top is
    signal RST_internal, CLK_internal, CLK_BTN : std_logic;
    signal SW_internal  : std_logic_vector(3 downto 0);
    signal LED_internal : std_logic_vector(7 downto 0);
    signal Seg_internal : std_logic_vector(6 downto 0);

begin

    SW_internal <= not SW;
    RST_internal <= not RST;
    CLK_internal <= not CLK;

        U_BTN : entity work.One_Pulse_Button
        port map(
            clk       => CLK_Nano,
            btn       => CLK_internal,  
            pulse_out => CLK_BTN
        );

    UUT : entity work.VBC1_Top
        port map(
            CLK => CLK_BTN,
            RST => RST_internal,
            SW  => SW_internal,
            LED_Op => open,
            LED_IO => open,
            LED => LED_internal,
            Seg => Seg_internal,
            M1 => open,
            M2 => open,
            M3 => open,
            M4 => open,
            M5 => open,
            M6 => open,
            Load_R0  => open,
            Load_R1  => open,
            Load_OP  => open,
            Z0 => open,
            Z1 => open,
            Load_DR  => open,
            Load_LED => open,
            Load_SEG => open,
            IR => open,
            DI          => open,
            R0          => open,
            R1          => open,
            mem_address => open,
            Ir_3_to_0   => open
        );

    LED <= not LED_internal;
    Seg <= not Seg_internal;

end Behavioral;
