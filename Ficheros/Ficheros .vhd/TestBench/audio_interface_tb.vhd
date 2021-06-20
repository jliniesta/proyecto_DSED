----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 30.11.2020 09:47:36
-- Module Name: Audio interface
-- Design Name: Testbench de la Interfaz de audio
-- File Name: audio_interface_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Testbench para comprobar el correcto funcionamiento de la interfaz de audio
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity audio_interface_tb is
end audio_interface_tb;

architecture Behavioral of audio_interface_tb is

component audio_interface is
    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           --Recording ports
           --To/From the controller
           record_enable : in STD_LOGIC;
           sample_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready : out STD_LOGIC;
           
           --To/From the microphone
           micro_clk : out STD_LOGIC;
           micro_data : in STD_LOGIC;
           micro_LR : out STD_LOGIC;

           --Playing ports
           --To/From the controller
           play_enable : in STD_LOGIC;
           sample_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_request : out STD_LOGIC;
           
           --To/From the mini-jack
           jack_sd : out STD_LOGIC;
           jack_pwm : out STD_LOGIC);
end component;

--input signal declaration
signal reset, clk_12megas, record_enable, micro_data, play_enable: STD_LOGIC := '0';
signal sample_in: STD_LOGIC_VECTOR (sample_size - 1 downto 0) := (others => '0');

--output signals declaration
signal sample_out_ready, micro_clk, micro_LR, sample_request, jack_sd, jack_pwm : STD_LOGIC := '0';
signal sample_out: STD_LOGIC_VECTOR (sample_size - 1 downto 0) := (others => '0');

-- Clock period definitions
constant clk_period : time := 83.33 ns; --Periodo de 12 MHz

--input signals for generating random signal micro_data
signal a,b,c : STD_LOGIC := '0';

begin

uut_audio_interface : audio_interface
    PORT MAP (
    clk_12megas => clk_12megas,
    reset => reset,
    record_enable => record_enable,
    sample_out => sample_out,
    sample_out_ready => sample_out_ready,
    micro_clk => micro_clk,
    micro_data => micro_data,
    micro_LR => micro_LR,
    play_enable => play_enable,
    sample_in => sample_in,
    sample_request => sample_request,
    jack_sd => jack_sd,
    jack_pwm => jack_pwm
    );

-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clk_12megas <= '0';
    wait for clk_period/2;
    clk_12megas <= '1';
    wait for clk_period/2;
end process;

-- micro_data es una señal pseudo-aleatoria
a <= not a after 1300 ns;
b <= not b after 2100 ns;
c <= not c after 3700 ns;
micro_data <= a xor b xor c;

-- Stimulus process
stim_proc: process
begin
    reset<='1';
    play_enable <='0';
    record_enable <='0';
    wait for 200 ns;
    reset<='0';
    play_enable <='1';
    record_enable <='1';
    sample_in <= "00000000";
    wait for 50 us;
    sample_in <= "10011010";
    wait for 50 us;
    sample_in <= "11001011";
    wait for 50 us;
    sample_in <= "11111111";
    wait for 500 us;
end process;

end Behavioral;
