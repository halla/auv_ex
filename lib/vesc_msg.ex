defmodule VescMsg do

"""

Decimal values are floats in the other end, encoded as integers, by first shifting numbers left.

Be careful, this message format changes over time. Be sure to match with the correct version on the other side.

See https://github.com/vedderb/bldc/blob/master/commands.c
See https://github.com/vedderb/bldc/blob/master/buffer.c

"""


  def parse_msg(4,
    <<
    temp_fet::16-integer,
    temp_motor::16-integer,
    current_motor::32-integer,
    current_in::32-integer,
    id::32-integer,
    iq::32-integer,
    duty_now::16-integer,
    rpm::32-integer,
    v_in::16-integer,
    amp_hours::32-integer,
    amp_hours_charged::32-integer,
    watt_hours::32-integer,
    watt_hours_charged::32-integer,
    tachometer::32-integer,
    tachometer_abs::32-integer,
    #rest::binary
    #fault_code::integer
    rest::binary
  >>) do
    %{
      # v_in: v_in,
    temp_fet: temp_fet / 10,
    temp_motor: temp_motor / 10,
    current_motor: current_motor / 100,
    current_in: current_in / 100,
    duty_now: duty_now / 1000,
    rpm: rpm,
   }
    #IO.puts("duty: " + duty_now)

  end
  def parse_msg(4, msg) do
    %{}
  end
end
