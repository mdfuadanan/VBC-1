library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VBC1_Data_Path is port(
    M1,M2,M3,M4, M5: in std_logic; -- multiplexer select lines
    load_r0, load_r1,load_op : in std_logic; -- load registers
    IR : in std_logic_vector (7 downto 0); -- instruction input
    DI: in std_logic_vector (3 downto 0); -- data input
    clk, rst: in std_logic; -- clock and reset
    op : out std_logic_vector(3 downto 0); -- output register
    r0,r1 : out std_logic_vector(3 downto 0)
);
end VBC1_Data_Path;


architecture dataflow of VBC1_Data_Path is
    signal op_reg : std_logic_vector(3 downto 0);
    signal M1_out,M2_out,M3_out,M4_out,M5_out, ALU_OUT,r0_out ,r1_out: std_logic_vector(3 downto 0);

    component mux2_1 is
        port (
            sel: in std_logic;
            ch0,ch1: in std_logic_vector(3 downto 0);
            y: out std_logic_vector(3 downto 0)
        );
    end component;
    
    component loadable_reg_4_bit is
        port (
            rst, clk, load_r : in std_logic;
            d : in std_logic_vector (3 downto 0);
            q : out std_logic_vector (3 downto 0)
        );
    end component;
    
    component VBC1_ALU is
        port (
            IR : in std_logic_vector (2 downto 0);
            r_ir, r0_r1 : in std_logic_vector (3 downto 0);
            ALU_OUT : out std_logic_vector (3 downto 0)
        );
    end component;

begin

    --------------------------------------------------
    -- MUX2: Select R0 or R1 → R0_R1
    --------------------------------------------------
    MUX2: mux2_1 port map(
        sel => M2,
        ch0 => r0_out,
        ch1 => r1_out,
        y   => M2_out
    );

    --------------------------------------------------
    -- MUX4: Select R0 or R1 → R0_1
    --------------------------------------------------
    MUX4: mux2_1 port map(
        sel => M4,
        ch0 => r0_out,
        ch1 => r1_out,
        y   => M4_out
    );

    --------------------------------------------------
    -- MUX5: Select R0_1 or immediate → R_IR
    --------------------------------------------------
    MUX5: mux2_1 port map(
        sel => M5,
        ch0 => M4_out,
        ch1 => IR(3 downto 0),
        y   => M5_out
    );

    --------------------------------------------------
    -- ALU
    --------------------------------------------------
    ALU1: VBC1_ALU port map(
        IR      => IR(7 downto 5),
        r_ir    => M5_out,
        r0_r1   => M2_out,
        ALU_OUT => ALU_OUT
    );

    --------------------------------------------------
    -- MUX3: Select between R0_R1 and ALU_OUT → R_ALU
    --------------------------------------------------
    MUX3: mux2_1 port map(
        sel => M3,
        ch0 => M2_out,
        ch1 => ALU_OUT,
        y   => M3_out
    );

    --------------------------------------------------
    -- MUX1: Select between R_ALU and DI → R_ALU_DI
    --------------------------------------------------
    MUX1: mux2_1 port map(
        sel => M1,
        ch0 => M3_out,
        ch1 => DI,
        y   => M1_out
    );

    --------------------------------------------------
    -- Register R0
    --------------------------------------------------
    REG_R0: loadable_reg_4_bit port map(
        rst    => rst,
        clk    => clk,
        load_r => load_r0,
        d      => M1_out,
        q      => r0_out
    );

    --------------------------------------------------
    -- Register R1
    --------------------------------------------------
    REG_R1: loadable_reg_4_bit port map(
        rst    => rst,
        clk    => clk,
        load_r => load_r1,
        d      => M1_out,
        q      => r1_out
    );

    --------------------------------------------------
    -- Output Register OP
    --------------------------------------------------
    REG_OP: loadable_reg_4_bit port map(
        rst    => rst,
        clk    => clk,
        load_r => load_op,
        d      => M2_out,
        q      => op_reg
    );
    r0<= r0_out;
    r1<= r1_out;
    op <= op_reg;
end dataflow;