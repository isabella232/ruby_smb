#!/usr/bin/ruby

# This example script is used for testing the writing to a file.
# It will attempt to connect to a specific share and then write to a specified file.
# Example usage: ruby write_file.rb 192.168.172.138 msfadmin msfadmin TEST_SHARE test.txt "data to write"
# This will try to connect to \\192.168.172.138\TEST_SHARE with the msfadmin:msfadmin credentials
# and write "data to write" the file test.txt

require 'bundler/setup'
require 'ruby_smb'

address      = ARGV[0]
username     = ARGV[1]
password     = ARGV[2]
share        = ARGV[3]
file         = ARGV[4]
data         = ARGV[5]
smb_versions = ARGV[6]&.split(',') || ['1','2','3']

path     = "\\\\#{address}\\#{share}"

sock = TCPSocket.new address, 445
dispatcher = RubySMB::Dispatcher::Socket.new(sock)

client = RubySMB::Client.new(dispatcher, smb1: smb_versions.include?('1'), smb2: smb_versions.include?('2'), smb3: smb_versions.include?('3'), username: username, password: password)
protocol = client.negotiate
status = client.authenticate

puts "#{protocol} : #{status}"

begin
  tree = client.tree_connect(path)
  puts "Connected to #{path} successfully!"
rescue StandardError => e
  puts "Failed to connect to #{path}: #{e.message}"
end

file = tree.open_file(filename: file, write: true, disposition: RubySMB::Dispositions::FILE_OVERWRITE_IF)

result = file.write(data: data)
puts result.to_s
file.close
