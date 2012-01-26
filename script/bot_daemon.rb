#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

Daemons.run(File.join(File.dirname(__FILE__), 'bot'), :dir_mode => :normal, :dir => File.expand_path(File.join(File.dirname(__FILE__),'..','tmp','pids')))