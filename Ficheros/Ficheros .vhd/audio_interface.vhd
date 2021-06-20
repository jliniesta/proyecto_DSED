----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 27.11.2020 13:28:07
-- Module Name: Audio interface
-- Design Name: Interfaz de audio
-- File Name: audio_interface.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Instanciación de cada uno de estos bloques en un único módulo que formará
--              la interfaz de audio completa
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

package package_dsed is
    constant sample_size: integer := 8;
end package_dsed;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity audio_interface is
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
end audio_interface;

architecture Behavioral of audio_interface is

component FSMD_microphone
    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_4_cycles : in STD_LOGIC;
           micro_data : in STD_LOGIC;
           sample_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready : out STD_LOGIC);
end component;

component en_4_cycles
    Port ( 
            clk_12megas : in STD_LOGIC;
            reset : in STD_LOGIC;
            clk_3megas : out STD_LOGIC;
            en_2_ciclos : out STD_LOGIC;
            en_4_ciclos : out STD_LOGIC);
end component;

component pwm 
    Port ( 
           clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_2_cycles : in STD_LOGIC;
           sample_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_request : out STD_LOGIC;
           pwm_pulse : out STD_LOGIC);
end component;

signal en_2_ciclos, enable_4_cycles, enable_microphone, enable_pwm : STD_LOGIC;

begin

uut_enable: en_4_cycles
    PORT MAP (
        reset=>reset,
        clk_12megas=>clk_12megas,
        clk_3megas=>micro_clk,
        en_2_ciclos=>en_2_ciclos,
        en_4_ciclos=>enable_4_cycles);

enable_microphone <= enable_4_cycles and record_enable;
enable_pwm <= en_2_ciclos and play_enable;

uut_microphone : FSMD_microphone
    PORT MAP (
    clk_12megas => clk_12megas,
    reset => reset,
    enable_4_cycles => enable_microphone,
    micro_data => micro_data,
    sample_out => sample_out,
    sample_out_ready => sample_out_ready);
    
uut_pwm : pwm
    PORT MAP (    
    reset=>reset,    
    clk_12megas=>clk_12megas,    
    en_2_cycles=>enable_pwm,    
    sample_in=>sample_in,   
    sample_request=>sample_request,    
    pwm_pulse=>jack_pwm);    
            
micro_LR <= '0';
jack_sd <= '1';

end Behavioral;
