library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VBC1_Board_Top is
    port(
        CLK     : in  std_logic;
        RST     : in  std_logic;
        SW      : in  std_logic_vector(3 downto 0);
        LED     : out std_logic_vector(7 downto 0);
        Seg     : out std_logic_vector(6 downto 0)
    );
end VBC1_Board_Top;

architecture Behavioral of VBC1_Board_Top is

    -- Component declaration of VBC1_Top
    component VBC1_Top is
        port(
            CLK : in std_logic;
            RST : in std_logic;
            SW  : in std_logic_vector(3 downto 0);
            LED : out std_logic_vector(7 downto 0);
            Seg : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    -- Instantiate ONLY VBC1_Top
    UUT: VBC1_Top
        port map(
            CLK => CLK,
            RST => RST,
            SW  => SW,
            LED => LED,
            Seg => Seg
        );

end Behavioral;