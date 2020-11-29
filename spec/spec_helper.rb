require 'json'
require 'rspec'
require 'active_support/core_ext/object'

require_relative 'mock/miq-queue'
require_relative '../lib/miq_var'
MiqAeMethodService::MiqAeServiceMiqQueue::TASKS << TaskMock.new(data: {"string1"=>"hello world", "json1"=>{"a"=>"aaa", "b"=>"bbb"}})
MiqAeMethodService::MiqAeServiceMiqQueue::TASKS << TaskMock.new(data: {"string2"=>"hello world", "json2"=>{"c"=>"ccc", "d"=>"ddd"}})