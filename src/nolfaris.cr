# Temp primitive version used to generate binaries for endiver (for testing)
module Nolfaris
  extend self

  save_file("out.nk")

  DATA = [
    ["lstr", 0x05_u16, "foo"],
    ["lstr", 0x06_u16, "bar"],
    ["add", 0x05_u16, 0x05_u16, 0x06_u16],
    ["log", 0x05_u16],
    ["stop"]
  ] of Array(UInt16 | String | Int32)


  def dump_data(data)
    array = [] of UInt8
    data.each do |instruction|
      case instruction[0]
      when "add"
        array += [0x00_u8] + dump_three_regs(instruction)
      when "addi"
        array += [0x01_u8] + dump_two_regs_and_int32(instruction)
      when "beq"
        array += [0x02_u8] + dump_two_regs_and_int32(instruction)
      when "bge"
        array += [0x03_u8] + dump_two_regs_and_int32(instruction)
      when "bgt"
        array += [0x04_u8] + dump_two_regs_and_int32(instruction)
      when "ble"
        array += [0x05_u8] + dump_two_regs_and_int32(instruction)
      when "blt"
        array += [0x06_u8] + dump_two_regs_and_int32(instruction)
      when "bne"
        array += [0x07_u8] + dump_two_regs_and_int32(instruction)
      when "beqz"
        array += [0x08_u8] + dump_one_reg_and_int32(instruction)
      when "bgez"
        array += [0x09_u8] + dump_one_reg_and_int32(instruction)
      when "bgtz"
        array += [0x0a_u8] + dump_one_reg_and_int32(instruction)
      when "blez"
        array += [0x0b_u8] + dump_one_reg_and_int32(instruction)
      when "bltz"
        array += [0x0c_u8] + dump_one_reg_and_int32(instruction)
      when "bnez"
        array += [0x0d_u8] + dump_one_reg_and_int32(instruction)
      when "copy"
        array += [0x14_u8] + to_byte_array(instruction[1].as(UInt16)) + to_byte_array(instruction[2].as(UInt16))
      when "div"
        array += [0x0f_u8] + dump_three_regs(instruction)
      when "divi"
        array += [0x10_u8] + dump_two_regs_and_int32(instruction)
      when "j"
        array += [0x12_u8] + to_byte_array(instruction[1].as(Int32))
      when "jr"
        array += [0x13_u8] + to_byte_array(instruction[1].as(UInt16))
      when "jal"
        array += [0x30_u8] + to_byte_array(instruction[1].as(Int32))
      when "li"
        array += [0x17_u8] + dump_one_reg_and_int32(instruction)
      when "log"
        array += [0x19_u8] + to_byte_array(instruction[1].as(UInt16))
      when "lstr"
        array += [0x1b_u8] + to_byte_array(instruction[1].as(UInt16)) + dump_string(instruction[2].as(String))
      when "stop"
        array << 0x2d_u8



      end
    end
    return array
  end

  def dump_two_regs_and_int32(instruction)
    return to_byte_array(instruction[1].as(UInt16)) + to_byte_array(instruction[2].as(UInt16)) + to_byte_array(instruction[3].as(Int32))
  end

  def dump_one_reg_and_int32(instruction)
    return to_byte_array(instruction[1].as(UInt16)) + to_byte_array(instruction[2].as(Int32))
  end

  def dump_three_regs(instruction)
    return to_byte_array(instruction[1].as(UInt16)) + to_byte_array(instruction[2].as(UInt16)) + to_byte_array(instruction[3].as(UInt16))
  end

  def save_file(path : String)
    array = dump_data(DATA)
    File.open(path, "w") do |f|
      f.write array.to_unsafe.as(UInt8*).to_slice(array.size)
    end
  end

  def to_byte_array(value : UInt32 | Int32)
    [value.to_u8, (value / 0x100).to_u8, (value / 0x10000).to_u8, (value / 0x1000000).to_u8 ]
  end

  def to_byte_array(value : UInt16 | Int16)
    [value.to_u8, (value / 0x100).to_u8]
  end

  def dump_string(string : String)
    return to_byte_array(string.bytesize.to_i16) + string.bytes
  end
end

