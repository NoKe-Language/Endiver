
a = [2, 42, "test", "gfdjk", 42.3]
b = [5, 1, "test", 3, 43.1]

5.times do |i|
  n = a[i]
  puts n.is_a? a.class
end