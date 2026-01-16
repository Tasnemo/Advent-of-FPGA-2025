library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpga is
  port (
    clk  : in std_logic; -- 100MHz clock
    btnC : in std_logic; -- Reset (Center button)
    btnU : in std_logic; -- Start (Up button)
    led  : out std_logic_vector(15 downto 0) -- LEDs (Result)
  );
end fpga;

architecture behavioral of fpga is

  signal reset   : std_logic;
  signal start   : std_logic;
  signal done    : std_logic;
  signal count   : std_logic_vector(15 downto 0);
  signal led_int : std_logic_vector(15 downto 0);

begin

  -- Input aliases
  reset <= btnC;
  start <= btnU;

  -- Instantiate Solver
  u_solver : entity work.solver
    port map
    (
      clk     => clk,
      reset   => reset,
      start   => start,
      done    => done,
      count   => count,
      led_out => led_int
    );

  -- Output assignment
  led <= led_int;

end behavioral;
