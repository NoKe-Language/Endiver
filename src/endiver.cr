# Entry point
Endiver.read_file("out.nk")

# TODO: Write documentation for `Endiver`
module Endiver
  VERSION = "0.1.0"

  REG = Array(Primary).new(10, 0)




  extend self

  def read_file(path : String)
    if File.exists?(path)
      File.open(path, "r") do |f|
        f.read_at(0, f.size.to_i32) do |io|
          # Get file content in bytes
          bytes = Bytes.new(f.size)
          io.read(bytes)
          index = 0
          # Process content
          stop = false
          while !stop && index < bytes.size
            inst = bytes[index]
            case inst
            when 0x00_u8 # add
              REG[load_uint16(bytes, index + 1)] = REG[load_uint16(bytes, index + 3)].as(Int32) + REG[load_uint16(bytes, index + 5)].as(Int32)
              index += 7
            when 0x01_u8 # addi
              REG[load_uint16(bytes, index + 1)] = REG[load_uint16(bytes, index + 3)].as(Int32) + load_int32(bytes, index + 5)
              index += 9
            when 0x02_u8..0x07_u8 # beq, bge, bgt, ble, blt, bne
              i = bytes[index]
              a = REG[load_uint16(bytes, index + 1)].as(Int32)
              b = REG[load_uint16(bytes, index + 3)].as(Int32)
              if (i == 2 && a == b) || (i == 3 && a >= b) || (i == 4 && a > b) || (i == 5 && a <= b) || (i == 6 && a < b) || (i == 7 && a != b)
                index = load_int32(bytes, index + 5)
              else
                index += 9
              end
            when 0x08_u8..0x0d_u8 #beqz, bgez, bgtz, blez, bltz, bnez
              
              i = bytes[index]
              a = REG[load_uint16(bytes, index + 1)].as(Int32)
              if (i == 8 && a == 0) || (i == 9 && a >= 0) || (i == 10 && a > 0) || (i == 11 && a <= 0) || (i == 12 && a < 0) || (i == 13 && a != 0)
                index = load_int32(bytes, index + 3)
              else
                index += 7
              end
            when 0x0f_u8 #div
              REG[load_uint16(bytes, index + 1)] = REG[load_uint16(bytes, index + 3)].as(Int32) / REG[load_uint16(bytes, index + 5)].as(Int32)
              index += 7
            when 0x10_u8 #divi
              REG[load_uint16(bytes, index + 1)] = REG[load_uint16(bytes, index + 3)].as(Int32) / load_int32(bytes, index + 5)
              index += 9
            when 0x12_u8 # j
              index = load_int32(bytes, index + 1)
            when 0x13_u8 # jr
              index = REG[load_uint16(bytes, index + 1)].as(Int32)
            when 0x14_u8 # copy
              REG[load_uint16(bytes, index + 1)] = REG[load_uint16(bytes, index + 3)]
              index += 5
            when 0x30_u8 # jal
              REG[2] = index + 5
              index = load_int32(bytes, index + 1)
            when 0x17_u8 # li
              reg = load_uint16(bytes, index + 1)
              REG[reg] = load_int32(bytes, index + 3)
              index += 7
            when 0x19_u8 # log
              reg = load_uint16(bytes, index + 1)
              puts REG[reg]
              index += 3
            when 0x1b_u8 # lstr
              reg = load_uint16(bytes, index + 1)
              REG[reg], index = load_string(bytes, index + 3)
            when 0x2d_u8 # stop
              stop = true
            else
              puts "Unknown instruction : 0x%X" % bytes[index]
              stop = true
            end
          end
          if index >= bytes.size
            puts "Terminated (dropped off bottom)"
          end
        end
      end
    else
      puts "Invalid file : %s" % path
    end
  end

  def load_string(bytes : Bytes, from : Int32)
    string_length = bytes[from].to_u16 + bytes[from + 1].to_u16 * 0x100
    string = String.new(bytes[from + 2, string_length])
    return string, from + 2 + string_length
  end

  def load_int32(bytes : Bytes, from : Int32)
    return (bytes[from].to_u32 + bytes[from + 1].to_u32 * 0x100 + bytes[from + 2].to_u32 * 0x10000 + bytes[from + 3].to_u32 * 0x1000000).to_i32
  end

  def load_uint16(bytes : Bytes, from : Int32)
    return bytes[from].to_u16 + bytes[from + 1].to_u16 * 0x100
  end

  alias Primary = (Int32 | Float32 | UInt8 | String | Array(Primary))
end
