library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rom_pkg.all;

entity tb_fpga is
end tb_fpga;

architecture sim of tb_fpga is

  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal led   : std_logic_vector(15 downto 0);

  constant CLK_PERIOD : time := 10 ns;

begin

  u_fpga : entity work.fpga
    port map
    (
      clk   => clk,
      reset => reset,
      led   => led
    );

  clk_process : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  stim_proc : process
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait for 2 ms;

    report "Simu finished";

    wait;
  end process;

end sim;
