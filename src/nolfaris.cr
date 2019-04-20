# Temp primitive version used to generate binaries for endiver (for testing)
module Nolfaris
  extend self

  save_file("out.nk")

  DATA = [
    ["li", 0x5_u16, 1],
    ["li", 0x6_u16, 0],
    ["add", 0x6_u16, 0x5_u16, 0x6_u16],
    ["log", 0x6_u16],
    ["j", 14]
  ]

  def dump_data(data)
    array = [] of UInt8
    data.each do |instruction|
      case instruction[0]
      when "add"
        array += [0x00_u8] + to_byte_array(instruction[1].as(UInt16)) + to_byte_array(instruction[2].as(UInt16)) + to_byte_array(instruction[3].as(UInt16))
      when "j"
        array += [0x12_u8] + to_byte_array(instruction[1].as(Int32))
      when "li"
        array += [0x17_u8] + to_byte_array(instruction[1].as(UInt16)) + to_byte_array(instruction[2].as(Int32))
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

