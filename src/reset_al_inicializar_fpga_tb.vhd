library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity reset_al_inicializar_fpga_tb is
end reset_al_inicializar_fpga_tb;

architecture tb of reset_al_inicializar_fpga_tb is
    constant periodo : time := 1 sec;
    signal clk : std_logic;
    signal nreset_in : std_logic;
    signal nreset_out : std_logic;
begin

    U_DUT : entity reset_al_inicializar_fpga port map(
        clk => clk,
        nreset_in => nreset_in,
        nreset_out => nreset_out
    );

    reloj : process
    begin
        clk <= '0';
        wait for periodo/2;
        clk <= '1';
        wait for periodo/2;
    end process;
    evaluacion : process
    begin
        nreset_in <= '1';
        wait until rising_edge(clk);
        wait for periodo/4;
        assert not nreset_out;
        wait for 2*periodo;
        assert nreset_out;
        nreset_in <= '0';
        wait for periodo;
        assert not nreset_out;
        nreset_in <= '1';
        wait for periodo;
        assert nreset_out;
        finish;
    end process;
end tb ; -- tb
