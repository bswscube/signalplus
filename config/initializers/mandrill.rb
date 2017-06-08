require 'mandrill'

MANDRILL_CLIENT = Mandrill::API.new(ENV['MANDRILL_API_KEY'])
