defmodule VescFrame do
  @behaviour Circuits.UART.Framing

  @moduledoc """

  """

  def init(_args) do
    {:ok, <<>>}
  end

  # or tx_buffer?
  def add_framing(data, rx_buffer) when is_binary(data) do
    # No processing - assume the app knows to send the right number of bytes
    # data length
    length = byte_size(data)
    start = if length < 256 do 2 else 3 end
    crc = CRC.crc(:crc_16_xmodem, data)
    framed = <<start, length>> <> data <> <<crc::16, 3>>
    IO.puts(inspect framed, limit: :infinity)
    # decide short/long
    # start byte, length byte(s), data, crc, ed
    {:ok, framed, rx_buffer}
  end

  def frame_timeout(rx_buffer) do
    # On a timeout, just return whatever was in the buffer
    {:ok, [rx_buffer], <<>>}
  end

  def flush(:transmit, rx_buffer), do: rx_buffer
  def flush(:receive, _rx_buffer), do: <<>>
  def flush(:both, _rx_buffer), do: <<>>

  def remove_framing(data, rx_buffer) do
    process_data(rx_buffer <> data, [])
  end

  defp process_data(<<2, len::8, body::binary>> = data, messages) do
    IO.puts(inspect(data, limit: :infinity))

    process_data(len, body, messages)
  end

  defp process_data(<<3, len::16, body::binary>>, messages) do
    IO.puts("long")
    process_data(len, body, messages)
  end

  defp process_data(len, body, messages) do
    IO.puts(inspect(body, limit: :infinity))
    l = (len-1)*8
    <<cmd::8, data::size(l), crc::16, 3::8, rest::binary>> = body
    message = %{cmd: cmd, data: :binary.encode_unsigned(data)}
    process_data(rest, messages ++ [message])
  end


  defp process_data(<<>>, messages) do
    {:ok, messages, <<>>}
  end

  defp process_data(partial, messages) do
    {:in_frame, messages, partial}
  end
end
