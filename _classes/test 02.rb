
start = 4
length = 3
my_string = "0123456789"
a =  my_string.slice(0,start)
b =  my_string.slice(start,length)
c =  my_string.slice(start + length, my_string.length-1)

puts a + c