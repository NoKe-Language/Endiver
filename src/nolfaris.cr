# Temp primitive version used to generate binaries for endiver (for testing)
module Nolfaris
  extend self

  save_file("out.nk")

  def save_file(path : String)
    # lstr $s0, "Hello world ! :)"
    array : Array(UInt8) = [0x02_u8, 0x00_u8, 0x00_u8, 0x00_u8, 0x1b_u8, 0x02_u8, 0x00_u8] + dump_string("Hello world ! :)") + [0x1b_u8, 0x05_u8, 0x00_u8] + dump_string("Deuxième string")
    
    File.open(path, "w") do |f|
      f.write array.to_unsafe.as(UInt8*).to_slice(array.size)
    end
  end

  def dump_string(string : String)
    return [string.bytesize.to_u8, (string.bytesize.to_u16 / 0x100).to_u8] + string.bytes
  end
end

