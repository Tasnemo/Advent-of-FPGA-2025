library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpga is
  port (
    clk   : in std_logic;
    reset : in std_logic;
    led   : out std_logic_vector(15 downto 0)
  );
end fpga;

architecture behavioral of fpga is

  signal done    : std_logic;
  signal count   : std_logic_vector(15 downto 0);
  signal led_int : std_logic_vector(15 downto 0);

begin

  --
  u_solver : entity work.solver
    port map
    (
      clk     => clk,
      reset   => reset,
      done    => done,
      count   => count,
      led_out => led_int
    );

  -- Output 
  led <= led_int;

end behavioral;
