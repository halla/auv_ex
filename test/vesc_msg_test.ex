defmodule VescMsgTest do
  use ExUnit.Case
  doctest VescMsg


  test "successfully parses valid state message" do
    msg_raw = <<1, 71, 252, 183, 0, 0, 0, 33, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 34, 0, 49, 0, 0, 19, 86, 0, 242, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 57, 0, 0, 0, 0, 0, 0, 122, 111, 0, 0, 124, 43, 0, 7, 153, 116, 160, 6, 0, 0, 0, 0, 0, 0>>
    msg = VescMsg.parse_msg(4, msg_raw)
    IO.puts(inspect(msg))
  end

end
