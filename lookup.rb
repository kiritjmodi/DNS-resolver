def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")
# puts dns_raw

def parse_dns(dns_raw)
  dns_rec={}
  dns_raw.
  reject {|ln| ln.empty? }.
  map {|ln| ln.strip.split(", ") }.
  reject do |rec1|
    #puts rec1
    rec1.length==0  || rec1[0].start_with?('#')
  end.
  each_with_object ({}) do | rec1, rec2 |
    #puts rec1.to_s + "---" + rec2.to_s
    dns_rec[rec1[1]] = {type:rec1[0], target:rec1[2]}
  end
  #puts dns_rec
  dns_rec
end
def resolve (dns_rec, lookup_chain,domain)
  rec1=dns_rec[domain]
  if (!rec1)
    return["Error: rec not found #{domain}"]
  elsif rec1 [:type]== "CNAME"
    lookup_chain.push (rec1[:target])
    resolve(dns_rec,lookup_chain,rec1[:target])
  elsif rec1[:type]=="A"
  lookup_chain.push(rec1[:target])
  return lookup_chain
  else
    rerurn ["Invalid rec type #{domain}"]
  end
end
  # ..
# ..
#
# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
