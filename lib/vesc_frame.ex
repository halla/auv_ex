defmodule VescFrame do
  @behaviour Circuits.UART.Framing

  @moduledoc """
  Each message is 4 bytes. This framer doesn't do anything for the transmit
  direction, but for receives, it will collect bytes in batches of 4 before
  sending them up. The user can set up a framer timeout if they don't mind
  partial frames. This can be useful to resyncronize when bytes are dropped.
  """

  def init(_args) do
    {:ok, <<>>}
  end

  def add_framing(data, rx_buffer) when is_binary(data) do
    # No processing - assume the app knows to send the right number of bytes
    {:ok, data, rx_buffer}
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
