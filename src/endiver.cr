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


          number_of_instructions = bytes[0].to_u32 + bytes[1].to_u32 * 0x100 + bytes[2].to_u32 * 0x10000 + bytes[3].to_u32 * 0x1000000
          puts number_of_instructions

          index = 4
          # Process content
          number_of_instructions.times do
            inst = bytes[index]
            case inst
            when 0x1b_u8 #lstr
              reg = bytes[index + 1].to_u16 + bytes[index + 2].to_u16 * 0x100
              REG[reg], index = load_string(bytes, index + 3)
              puts REG
            else
              
            end
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
end


alias Primary = (Int32 | Float32 | UInt8 | String | Bool | Array(Primary))