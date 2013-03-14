require 'bundler'
Bundler.require

require 'minitest/autorun'
require 'mocha/setup'
require 'pry'

$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'backchat'
