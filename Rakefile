#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

YARD::Rake::YardocTask.new(:doc) do |t|
end

desc "Run tests"
task default: :test
