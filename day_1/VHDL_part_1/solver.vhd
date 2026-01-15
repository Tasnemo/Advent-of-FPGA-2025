library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rom_pkg.all;

entity solver is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    done    : out std_logic;
    count   : out std_logic_vector(15 downto 0);
    led_out : out std_logic_vector(15 downto 0)
  );
end solver;

architecture behavioral of solver is

  -- State Machine
  type state_type is (IDLE, FETCH, MODULO, UPDATE, FINISHED);
  signal state : state_type := IDLE;

  -- Internal Signals
  signal rom_addr : integer range 0 to ROM_DEPTH - 1 := 0;
  signal pos      : signed(15 downto 0)              := to_signed(50, 16); -- Initial Position 50
  signal zero_cnt : unsigned(15 downto 0)            := (others => '0');
  signal next_pos : signed(15 downto 0);

begin

  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state    <= IDLE;
        rom_addr <= 0;
        pos      <= to_signed(50, 16);
        zero_cnt <= (others => '0');
        done     <= '0';
        count    <= (others => '0');
        led_out  <= (others => '0');
        next_pos <= (others => '0');
      else
        case state is
          when IDLE =>
            state    <= FETCH;
            rom_addr <= 0;
            pos      <= to_signed(50, 16);
            zero_cnt <= (others => '0');
            done     <= '0';

          when FETCH =>
            -- Finding next pos
            next_pos <= pos + ROM(rom_addr);
            state    <= MODULO;

          when MODULO =>
            -- using +/- loop to modulo
            if next_pos < 0 then
              next_pos <= next_pos + 100;
            elsif next_pos >= 100 then
              next_pos <= next_pos - 100;
            else
              state <= UPDATE;
            end if;

          when UPDATE =>
            pos <= next_pos;

            if next_pos = 0 then
              zero_cnt <= zero_cnt + 1;
            end if;

            if rom_addr = ROM_DEPTH - 1 then
              state <= FINISHED;
            else
              rom_addr <= rom_addr + 1;
              state    <= FETCH;
            end if;

          when FINISHED =>
            done    <= '1';
            count   <= std_logic_vector(zero_cnt);
            led_out <= std_logic_vector(zero_cnt);

        end case;
      end if;
    end if;
  end process;

end behavioral;
