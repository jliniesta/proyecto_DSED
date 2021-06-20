----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 04.12.2020 11:29:26
-- Module Name: Filtro FIR Configurable
-- Design Name: Filtro FIR de 5 etapas
-- File Name: fir_filter.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Filtro FIR de 5 etapas con dos medios multiplicadores y un sumador
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity fir_filter is
    Port ( clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Sample_In : in signed (sample_size - 1 downto 0);
           Sample_In_enable : in STD_LOGIC;
           filter_select : in STD_LOGIC;
           Sample_Out : out signed (sample_size - 1 downto 0);
           Sample_Out_ready : out STD_LOGIC);
end fir_filter;

architecture Behavioral of fir_filter is

type state_type is (idle, state_0, state_1, state_2, state_3, state_4, state_5, state_6);

signal state, next_state : state_type;
signal c0, c1, c2, c3, c4 : signed (sample_size - 1 downto 0);
signal r0_reg, r1_reg, r2_reg, r0_next, r1_next, r2_next : SIGNED (sample_size - 1  downto 0);

signal registro1_reg, registro1_next : SIGNED (sample_size - 1  downto 0);
signal registro2_reg, registro2_next : SIGNED (sample_size - 1  downto 0);
signal registro3_reg, registro3_next : SIGNED (sample_size - 1  downto 0);
signal registro4_reg, registro4_next : SIGNED (sample_size - 1  downto 0);
signal registro5_reg, registro5_next : SIGNED (sample_size - 1  downto 0);
signal registro_salida_reg, registro_salida_next : SIGNED (sample_size - 1  downto 0);
signal registro_sample_out_reg, registro_sample_out_next : STD_LOGIC;
 
--LOW PASS
constant c0_LP, c4_LP : signed (sample_size - 1 downto 0) := to_signed(5, sample_size);     -- +0.039 * 2^7 = +4.992
constant c1_LP, c3_LP : signed (sample_size - 1 downto 0) := to_signed(31, sample_size);    -- +0.2422 * 2^7 = +31.0016
constant c2_LP : signed (sample_size - 1 downto 0) := to_signed(57, sample_size);           -- +0.4453 * 2^7 = +56.9984
--HIGH PASS
constant c0_HP, c4_HP : signed (sample_size - 1 downto 0) := to_signed(-1, sample_size);    -- -0.0078 * 2^7 = -0.9984
constant c1_HP, c3_HP : signed (sample_size - 1 downto 0) := to_signed(-26, sample_size);   -- -0.2031 * 2^7 = -25.9968
constant c2_HP : signed (sample_size - 1 downto 0) := to_signed(77, sample_size);           -- +0.6015 * 2^7 = +76.992

--mult
signal mult_out, mult_op1, mult_op2 : signed (sample_size - 1 downto 0);

--sum
signal sum_out, sum_op1, sum_op2 : signed (sample_size - 1 downto 0);

component sum
     Port ( sum_op1 : in signed (sample_size - 1 downto 0);
            sum_op2 : in signed (sample_size - 1 downto 0);
            sum_out : out signed (sample_size - 1 downto 0));
end component;

component mult
      Port ( mult_op1 : in signed (sample_size - 1 downto 0);
             mult_op2 : in signed (sample_size - 1 downto 0);
             mult_out : out signed (sample_size - 1 downto 0));
end component;

begin

uut_sum: sum
    PORT MAP (sum_op1=>sum_op1,
              sum_op2=>sum_op2,
              sum_out=>sum_out);
        
uut_mult: mult
     PORT MAP (mult_op1=>mult_op1,                                                                       
               mult_op2=>mult_op2,
               mult_out=>mult_out);

SYNC_PROC: process (clk, Reset)
begin

    if (Reset = '1') then
        r0_reg <= (others => '0');
        r1_reg <= (others => '0');
        r2_reg <= (others => '0');
        registro1_reg <= (others => '0');
        registro2_reg <= (others => '0');
        registro3_reg <= (others => '0');
        registro4_reg <= (others => '0');
        registro5_reg <= (others => '0');
        registro_salida_reg <= (others => '0');
        registro_sample_out_reg <= '0';
        state <= idle;
    elsif (rising_edge(clk)) then
        r0_reg <= r0_next;
        r1_reg <= r1_next;
        r2_reg <= r2_next;
        registro1_reg <= registro1_next;
        registro2_reg <= registro2_next;
        registro3_reg <= registro3_next;
        registro4_reg <= registro4_next;
        registro5_reg <= registro5_next;
        registro_salida_reg <= registro_salida_next;
        registro_sample_out_reg <= registro_sample_out_next;
        state <= next_state;
    end if;
    
end process;

BUFFER_FILTER: process(registro1_reg, registro2_reg, registro3_reg, registro4_reg,registro5_reg, sample_in, sample_in_enable)
begin

    registro1_next <= registro1_reg;
    registro2_next <= registro2_reg;
    registro3_next <= registro3_reg;
    registro4_next <= registro4_reg;
    registro5_next <= registro5_reg;
    
    if (sample_in_enable = '1') then
        registro1_next <= sample_in;
        registro2_next <= registro1_reg;
        registro3_next <= registro2_reg;
        registro4_next <= registro3_reg;
        registro5_next <= registro4_reg;
    end if;
    
 end process;

FILTER_TYPE: process (filter_select)
begin

    if ( filter_select = '1' ) then
        --High Pass
        c0 <= c0_HP;
        c1 <= c1_HP;
        c2 <= c2_HP;
        c3 <= c3_HP;
        c4 <= c4_HP;
    else 
        --Low Pass
        c0 <= c0_LP;
        c1 <= c1_LP;
        c2 <= c2_LP;
        c3 <= c3_LP;
        c4 <= c4_LP;
    end if;
    
end process;

OUTPUT_DECODE: process (state, r0_reg, r1_reg, r2_reg, registro1_reg, registro2_reg, registro3_reg, registro4_reg, registro5_reg, registro_salida_reg, registro_sample_out_reg, Sample_In, mult_out, sum_out, c0, c1, c2, c3, c4)
begin

    r0_next <= r0_reg;
    r1_next <= r1_reg;
    r2_next <= r2_reg;
    registro_sample_out_next <= registro_sample_out_reg;
    registro_salida_next <= registro_salida_reg;
    
    mult_op1 <= (others => '0');
    mult_op2 <= (others => '0');
    sum_op1 <= (others => '0');
    sum_op2 <= (others => '0');
    
    case state is 
        when idle =>
           registro_sample_out_next <= '0';

        when state_0 =>
            mult_op1 <= c0;
            mult_op2 <= registro1_reg;
            r0_next <= mult_out;
        
        when state_1 =>
            mult_op1 <= c1;
            mult_op2 <= registro2_reg;
            r0_next <= mult_out;
            r1_next <= r0_reg;
        
        when state_2 =>
            mult_op1 <= c2;
            mult_op2 <= registro3_reg;
            r0_next <= mult_out;
            r1_next <= r0_reg;
            sum_op1 <= r1_reg;
            sum_op2 <= (others => '0');
            r2_next <= sum_out;
        
        when state_3 =>
            mult_op1 <= c3;
            mult_op2 <= registro4_reg;
            r0_next <= mult_out;
            r1_next <= r0_reg;
            sum_op1 <= r1_reg;
            sum_op2 <= r2_reg;
            r2_next <= sum_out;
        
        when state_4 =>
            mult_op1 <= c4;
            mult_op2 <= registro5_reg;
            r0_next <= mult_out;
            r1_next <= r0_reg;
            sum_op1 <= r1_reg;
            sum_op2 <= r2_reg;
            r2_next <= sum_out;
        
        when state_5 =>
            r1_next <= r0_reg;
            sum_op1 <= r1_reg;
            sum_op2 <= r2_reg;
            r2_next <= sum_out;
        
        when state_6 =>
            sum_op1 <= r1_reg;
            sum_op2 <= r2_reg;
            registro_salida_next <= sum_out; 
            registro_sample_out_next <= '1';
        
    end case;
        
end process;

Sample_Out <= registro_salida_reg;
Sample_Out_ready <= registro_sample_out_reg;

NEXT_STATE_DECODE: process (state, Sample_In_enable)
begin
    next_state <= idle;
    case (state) is
        when idle => 
            if( Sample_In_enable = '1') then
                next_state <= state_0;
            end if;
        when state_0 =>
            next_state <= state_1;
        when state_1 =>
             next_state <= state_2;
        when state_2 =>
             next_state <= state_3;
        when state_3 =>
            next_state <= state_4;
        when state_4 =>
            next_state <= state_5;
        when state_5 =>
            next_state <= state_6;
        when state_6 =>
            next_state <= idle;
     end case;
end process;

end Behavioral;

