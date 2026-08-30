library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VBC1_Top is port(
    CLK,RST: in std_logic;
    SW: in std_logic_vector(3 downto 0);
    LED_Op,LED_IO : out std_logic_vector(3 downto 0);
    LED: out std_logic_vector(7 downto 0);
    Seg: out std_logic_vector(6 downto 0);
    M1,M2,M3,M4,M5,M6,Load_R0,Load_R1,Load_OP,Z0,Z1,Load_DR,Load_LED,Load_SEG: out std_logic;
    IR : out std_logic_vector (7 downto 0);
    DI,R0,R1,mem_address,Ir_3_to_0 : out std_logic_vector (3 downto 0)
    );
end VBC1_Top;

architecture behavioral of VBC1_Top is
    signal DI_i,R0_i,R1_i,mem_address_i,Ir_3_to_0_i,LED_Op_i,LED_IO_i :std_logic_vector(3 downto 0);
    signal Ir_i : std_logic_vector(7 downto 0);
    signal m1_i,m2_i,m3_i,m4_i,m5_i,m6_i,load_R0_i,load_R1_i,load_Op_i,z0_i,z1_i,Load_DR_i,Load_LED_i, Load_SEG_i : std_logic;

    component Instruction_Memory_16_Byte is port ( 
    clk     : in std_logic;
    we      : in std_logic;
    pc_addr : in std_logic_vector(3 downto 0);
    inst    : in std_logic_vector(7 downto 0);
    ir      : out std_logic_vector(7 downto 0)
    );
    end component;

    component VBC1_IO_Module is port(
    load_dr, load_led, load_seg, clk, rst : in  std_logic;
    sw : in std_logic_vector(3 downto 0);
    di, ld : out std_logic_vector(3 downto 0);
    seg : out std_logic_vector(6 downto 0)
    );
    end component;
    
    component VBC1_Data_Path is port(
    M1,M2,M3,M4, M5: in std_logic;
    load_r0, load_r1,load_op : in std_logic; 
    IR : in std_logic_vector (7 downto 0); 
    DI: in std_logic_vector (3 downto 0); 
    clk, rst: in std_logic; 
    op : out std_logic_vector(3 downto 0);
    r0,r1 : out std_logic_vector(3 downto 0)
    );
    end component;

    component VBC1_Instruction_Decoder is port(
    IR : in std_logic_vector (7 downto 0);
    r0, r1 : in std_logic_vector (3 downto 0);
    IR_7_to_5: out std_logic_vector (7 downto 5);
    IR_3_to_0 : out std_logic_vector(3 downto 0);
    M1,M2,M3,M4,M5,M6,Load_R0,Load_R1,Load_OP,Z0,Z1 : out std_logic
    );
    end component;

    component VBC1_RPC is port(
    rst, speed, load_new_a : in std_logic;
    new_a : in std_logic_vector (3 downto 0);
    prog_a : out std_logic_vector (3 downto 0)
    );
    end component;

begin

    IO_Mudule: VBC1_IO_Module port map(
    clk => CLK,
    rst => RST,
    sw =>SW,
    load_dr =>Load_DR_i,
    load_led=>Load_LED_i,
    load_seg=>Load_SEG_i,
    ld => LED_IO_i,
    seg => Seg,
    di => DI_i
    );

    Instruction_Decoder: VBC1_Instruction_Decoder port map (
    IR =>Ir_i,
    IR_3_to_0=>Ir_3_to_0_i,
    IR_7_to_5=> open,
    r0=>R0_i,
    r1 =>R1_i,
    M1=>m1_i,
    M2=>m2_i,
    M3=>m3_i,
    M4=>m4_i,
    M5=>m5_i,
    M6=>m6_i,
    Load_R0=>load_R0_i,
    Load_R1=> load_R1_i,
    Load_OP=>load_Op_i,
    Z0=>z0_i,
    Z1=>z1_i
    );

    Data_Path: VBC1_Data_Path port map (
    M1=>m1_i,
    M2=>m2_i,
    M3=>m3_i,
    M4=>m4_i, 
    M5=>m5_i,
    load_r0 =>load_R0_i, 
    load_r1=>load_R1_i,
    load_op=>load_Op_i,
    IR =>Ir_i,
    DI=>DI_i,
    clk=>CLK, 
    rst=>RST,
    op=>LED_Op_i,
    r0=>R0_i,
    r1=>R1_i
    );

    Pre_Loaded_Memory: Instruction_Memory_16_Byte port map (
    clk     => CLK,
    we      => '0',
    inst    => (others => '0'),
    pc_addr => mem_address_i,
    ir      => Ir_i
    );

    RPC:  VBC1_RPC port map(
    rst=>RST,
    speed=>CLK, 
    load_new_a =>m6_i,
    new_a =>Ir_3_to_0_i,
    prog_a =>mem_address_i
    );
    Load_DR_i   <= '1';
    Load_LED_i<= '1';
    Load_SEG_i <= '1';
    M1 <= m1_i;
    M2 <= m2_i;
    M3 <=m3_i;
    M4 <=m4_i;
    M5 <=m5_i;
    M6 <=m6_i;
    Load_R0<=load_R0_i;
    Load_R1<=load_R1_i;
    Load_Op<=load_Op_i;
    Z0<=z0_i;
    Z1<=z1_i;
    Load_DR<=Load_DR_i;
    Load_LED<=Load_LED_i;
    Load_SEG<=Load_SEG_i;
    DI<=DI_i;
    R0<=R0_i;
    R1<=R1_i;
    mem_address<=mem_address_i;
    Ir_3_to_0<=Ir_3_to_0_i;
    IR<= Ir_i;
    LED_Op <= LED_Op_i;
    LED_IO <= LED_IO_i;
    LED(3 downto 0)<=LED_IO_i;
    LED(7 downto 4)<= LED_Op_i;
end behavioral;