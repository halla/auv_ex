defmodule VescFrameTest do
  use ExUnit.Case
  doctest VescFrame


  test "successfully parses valid state message" do
    #msg_raw = <<2,65,4, 1, 71, 252, 183, 0, 0, 0, 33, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 34, 0, 49, 0, 0, 19, 86, 0, 242, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 57, 0, 0, 0, 0, 0, 0, 122, 111, 0, 0, 124, 43, 0, 7, 153, 116, 160, 6, 0, 0, 0, 0, 0, 0, 75, 172>>
    frame_start = <<2, 65>>
    frame_body = << 4, 1, 9, 252, 199, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 17, 0, 241, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 28, 0, 21, 16, 202, 128, 6, 0, 0, 0, 0, 0, 0>>
    frame_end = <<252, 34, 3>>
    frame = frame_start <> frame_body <> frame_end
    {:ok, framer} = VescFrame.init([])
    #{:in_frame, [], framer} = VescFrame.remove_framing(msg_raw, framer)
    {:ok, [msg], <<>>} = VescFrame.remove_framing(frame, framer)
    assert framer == <<>>
    <<cmd_expected::8, data_expected::binary>> = frame_body
    assert msg.cmd == cmd_expected
    assert msg.data == data_expected
  end

  test "framing of given short msg" do
    {:ok, framer} = VescFrame.init([])
    data = << 4, 1, 71, 252, 183, 0, 0, 0, 33, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 34, 0, 49, 0, 0, 19, 86, 0, 242, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 57, 0, 0, 0, 0, 0, 0, 122, 111, 0, 0, 124, 43, 0, 7, 153, 116, 160, 6, 0, 0, 0, 0, 0, 0>>
    data_framed = <<2,65,4, 1, 71, 252, 183, 0, 0, 0, 33, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 34, 0, 49, 0, 0, 19, 86, 0, 242, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 57, 0, 0, 0, 0, 0, 0, 122, 111, 0, 0, 124, 43, 0, 7, 153, 116, 160, 6, 0, 0, 0, 0, 0, 0, 75, 172,3>>
    {:ok, framed, <<>>} = VescFrame.add_framing(data, framer)
    assert framed == data_framed

  end

end
