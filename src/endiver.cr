# Entry point
Endiver.read_file("out.nk")

# TODO: Write documentation for `Endiver`
module Endiver
  VERSION = "0.1.0"

  REG = Array(Primary).new(10, 0)
  STACK = Array(Primary).new(10, 0)
  MEM = Array(Primary).new(10, 0)

  LOADER_U16 = Loader(UInt16).new
  LOADER_I32 = Loader(Int32).new
  LOADER_F32 = Loader(Float32).new

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
            # ---
            when 0x00_u8 # add
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_U16.load(bytes, index + 5)]
              if value1.class != String && value1.class != Array(Primary) && value2.class != String && value2.class != Array(Primary)
                REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Int32 | UInt8 | Float32) + value2.as(Int32 | UInt8 | Float32)
              elsif value1.class == value2.class == String
                REG[LOADER_U16.load(bytes, index + 1)] = value1.as(String) + value2.as(String)
              elsif value1.class == value2.class == Array(Primary)
                REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Array(Primary)) + value2.as(Array(Primary))
              end
              index += 7
              # ---
            when 0x01_u8 # addi
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_I32.load(bytes, index + 5)]
              REG[LOADER_U16.load(bytes, index + 1)] = REG[LOADER_U16.load(bytes, index + 3)].as(Int32 | UInt8 | Float32) + LOADER_I32.load(bytes, index + 5)
              index += 9
              # ---
            when 0x02_u8..0x07_u8 # beq, bge, bgt, ble, blt, bne
              i = bytes[index]
              a = REG[LOADER_U16.load(bytes, index + 1)].as(Int32)
              b = REG[LOADER_U16.load(bytes, index + 3)].as(Int32)
              if (i == 2 && a == b) || (i == 3 && a >= b) || (i == 4 && a > b) || (i == 5 && a <= b) || (i == 6 && a < b) || (i == 7 && a != b)
                index = LOADER_I32.load(bytes, index + 5)
              else
                index += 9
              end
              # ---
            when 0x08_u8..0x0d_u8 # beqz, bgez, bgtz, blez, bltz, bnez
              i = bytes[index]
              a = REG[LOADER_U16.load(bytes, index + 1)].as(Int32)
              if (i == 8 && a == 0) || (i == 9 && a >= 0) || (i == 10 && a > 0) || (i == 11 && a <= 0) || (i == 12 && a < 0) || (i == 13 && a != 0)
                index = LOADER_I32.load(bytes, index + 3)
              else
                index += 7
              end
              # ---
            when 0x0f_u8 # div
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_U16.load(bytes, index + 5)]
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) / value2.as(Float32 | Int32 | UInt8)
              index += 7
              # ---
            when 0x10_u8 # divi
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_I32.load(bytes, index + 5)].as(Int32)
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) / value2
              index += 9
              # ---
            when 0x12_u8 # j
              index = LOADER_I32.load(bytes, index + 1)
              # ---
            when 0x13_u8 # jr
              index = REG[LOADER_U16.load(bytes, index + 1)].as(Int32)
              # ---
            when 0x14_u8 # copy
              REG[LOADER_U16.load(bytes, index + 1)] = REG[LOADER_U16.load(bytes, index + 3)]
              index += 5
              # ---
            when 0x30_u8 # jal
              REG[2] = index + 5
              index = LOADER_I32.load(bytes, index + 1)
              # ---
            when 0x16_u8 # lf
              reg = LOADER_U16.load(bytes, index + 1)
              REG[reg] = LOADER_F32.load(bytes, index + 3)
              index += 7
              # ---
            when 0x17_u8 # li
              reg = LOADER_U16.load(bytes, index + 1)
              REG[reg] = LOADER_I32.load(bytes, index + 3)
              index += 7
              # ---
            when 0x19_u8 # log
              reg = LOADER_U16.load(bytes, index + 1)
              pp REG[reg]
              index += 3
              # ---
            when 0x1b_u8 # lstr
              reg = LOADER_U16.load(bytes, index + 1)
              REG[reg], index = load_string(bytes, index + 3)
              # ---
            when 0x1c_u8 # mod
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_U16.load(bytes, index + 5)]
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) % value2.as(Int32 | UInt8)
              index += 7
              # ---
            when 0x1d_u8 # modi
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_U16.load(bytes, index + 5)].as(Int32)
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) % value2
              index += 9
              # ---
            when 0x1e_u8 # mul
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_U16.load(bytes, index + 5)]
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) * value2.as(Float32 | Int32 | UInt8)
              index += 7
              # ---
            when 0x1f_u8 # muli
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_I32.load(bytes, index + 5)].as(Int32)
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) * value2
              index += 9
              # ---
            when 0x2c #sst
              STACK[REG[LOADER_U16.load(bytes, index + 7)].as(Int32) + LOADER_I32.load(bytes, index + 3)] = REG[LOADER_U16.load(bytes, index + 1)]
              puts STACK
              index += 9
              # ---
            when 0x2d_u8 # stop
              stop = true
              # ---
            when 0x2e_u8 # sub
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_U16.load(bytes, index + 5)]
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) - value2.as(Float32 | Int32 | UInt8)
              index += 7
            when 0x2f_u8 # subi
              value1 = REG[LOADER_U16.load(bytes, index + 3)]
              value2 = REG[LOADER_I32.load(bytes, index + 5)].as(Int32)
              REG[LOADER_U16.load(bytes, index + 1)] = value1.as(Float32 | Int32 | UInt8) - value2
              index += 9
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

  class Loader(T)
    def load(bytes : Bytes, from : Int = 0) : T
      (bytes.to_unsafe + from).as(T*).value
    end
  end

  alias Primary = (Int32 | Float32 | UInt8 | String | Array(Primary))
end
