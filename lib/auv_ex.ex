defmodule AuvEx do
  @moduledoc """
  Documentation for AuvEx.





    double v_in() const;
  double temp_mos1() const;
  double temp_mos2() const;
  double temp_mos3() const;
  double temp_mos4() const;
  double temp_mos5() const;
  double temp_mos6() const;
  double temp_pcb() const;
  double current_motor() const;
  double current_in() const;
  double rpm() const;
  double duty_now() const;
  double amp_hours() const;
  double amp_hours_charged() const;
  double watt_hours() const;
  double watt_hours_charged() const;
  double tachometer() const;
  double tachometer_abs() const;
  int fault_code() const;
  """

  use GenServer


  """
  COMM_FW_VERSION = 0,
	COMM_JUMP_TO_BOOTLOADER,
	COMM_ERASE_NEW_APP,
	COMM_WRITE_NEW_APP_DATA,
	COMM_GET_VALUES,
	COMM_SET_DUTY,
	COMM_SET_CURRENT,
	COMM_SET_CURRENT_BRAKE,
	COMM_SET_RPM,
	COMM_SET_POS,
	COMM_SET_HANDBRAKE,
	COMM_SET_DETECT,
	COMM_SET_SERVO_POS,
	COMM_SET_MCCONF,
	COMM_GET_MCCONF,
	COMM_GET_MCCONF_DEFAULT,
	COMM_SET_APPCONF,
	COMM_GET_APPCONF,
	COMM_GET_APPCONF_DEFAULT,
	COMM_SAMPLE_PRINT,
	COMM_TERMINAL_CMD,
	COMM_PRINT,
	COMM_ROTOR_POSITION,
	COMM_EXPERIMENT_SAMPLE,
	COMM_DETECT_MOTOR_PARAM,
	COMM_DETECT_MOTOR_R_L,
	COMM_DETECT_MOTOR_FLUX_LINKAGE,
	COMM_DETECT_ENCODER,
	COMM_DETECT_HALL_FOC,
	COMM_REBOOT,
	COMM_ALIVE,
	COMM_GET_DECODED_PPM,
	COMM_GET_DECODED_ADC,
	COMM_GET_DECODED_CHUK,
	COMM_FORWARD_CAN,
	COMM_SET_CHUCK_DATA,
	COMM_CUSTOM_APP_DATA,
	COMM_NRF_START_PAIRING
  """
  @cmds %{
    request_data: 4,
    set_duty: 5
  }


  def init(state) do
    {:ok, uart_pid} = start()
    connect(uart_pid)
    :timer.send_interval(100, self, :work)
    {:ok, %{uart_pid: uart_pid, duty: 0.05, running: true} }
  end

  def handle_info(:work, state) do
    if state.running do
    #  set_duty(state.uart_pid, state.duty)
      get_data(state.uart_pid)
      {:ok, response}= Circuits.UART.read(state.uart_pid, 1000)
      IO.puts(inspect response)
      VescMsg.parse_msg(response.cmd, response.data)
    end
    {:noreply, state}
  end

  def handle_call(:decelerate, _from, state) do
    state2 = Map.put(state, :duty, state.duty - 0.01)
    {:reply, state2, state2}
  end

  def handle_call(:accelerate, _from, state) do
    state2 = Map.put(state, :duty, state.duty + 0.01)
    {:reply, state2, state2}
  end

  def handle_call(:stop, _from, state) do
    state2 = Map.put(state, :running, false)
    {:reply, state2, state2}
  end

  """
    Frame start
      Payload: command id + data
    Frame end
  """
  # <2|3, len1, (len2), ... payload ..., crc1, crc2 ,3>
  # set_duty = 0

@frame_short 2
@frame_end <<3>>


  def start() do
    {:ok, pid} = Circuits.UART.start_link
    {:ok, pid}
  end

  def connect(pid) do
    Circuits.UART.open(pid, "ttyACM0", speed: 115200, active: false, framing: VescFrame)
  end

  def get_data(pid) do
    frame_start = <<@frame_short, 1>>
    payload = <<4>>
    crc = CRC.crc(:crc_16_xmodem, payload)
    <<crc1::8, crc2::8>> = <<crc::16>>
    packet = frame_start <> payload <> <<crc1, crc2>> <> @frame_end
    a = Circuits.UART.write(pid, packet)

  end

# void* VescInterface::Impl::rxThread(void)

  def rx(pid) do

  end

  def set_duty(pid, duty) do
    frame_start = <<2, 5>>
    frame_end = <<3>>
    command = <<5>>
    <<_v0::32, v1, v2, v3, v4>> = <<trunc(100000*duty)::64>>
    payload = command <> <<v1,v2,v3,v4>>
    crc = CRC.crc(:crc_16_xmodem, payload)
    <<crc1::8, crc2::8>> = <<crc::16>>

    packet = frame_start <> payload <> <<crc1, crc2>> <> frame_end
    a = Circuits.UART.write(pid, packet)
  end

  def set_duty(pid, duty, 0) do
  end

  def set_duty(pid, duty, secs) do
    set_duty(pid, duty)
    :timer.sleep(100);
    set_duty(pid, duty, secs-1)
  end

end
