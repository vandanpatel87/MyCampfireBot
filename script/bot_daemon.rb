#!/usr/bin/env ruby
require 'rubygems'
require 'daemons' 
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Daemons.run(File.join(File.dirname(__FILE__), 'bot'), :dir_mode => :normal, :dir => File.expand_path(File.join(File.dirname(__FILE__),'..','tmp','pids')))
