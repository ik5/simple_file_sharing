#!/usr/bin/env ruby
#

require 'rubygems'
require 'bundler/setup'

$app_path = "#{File.expand_path(File.dirname(__FILE__))}/" unless global_variables.include?('app_path')

Bundler.setup(:default)

require 'sinatra'
require 'sinatra/partial'

require "#{$app_path}app.rb"
run App


