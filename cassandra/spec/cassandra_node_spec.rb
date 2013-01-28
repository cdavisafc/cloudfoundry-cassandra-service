# Copyright (c) 2009-2011 VMware, Inc.
$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

require 'cassandra_service/cassandra_node'

module VCAP
  module Services
    module Cassandra
      class Node

      end
    end
  end
end

module VCAP
  module Services
    module Cassandra
      class CassandraError
          attr_reader :error_code
      end
    end
  end
end

describe "Cassandra service node" do
  include VCAP::Services::Cassandra

  before :all do
    @opts = get_node_test_config
    @opts.freeze
    @logger = @opts[:logger]
    # Setup code must be wrapped in EM.run
    EM.run do
      @node = Node.new(@opts)
      EM.add_timer(1) { EM.stop }
    end
  end

  before :each do
    @default_plan = "free"
    @default_opts = "default"
    @cassandraer = @node.provision(@default_plan)
    @cassandraer.should_not == nil
  end

  it "should provison a cassandra service with correct credential" do
    EM.run do
      @cassandraer.should be_instance_of Hash
      @cassandraer["port"].should be 5002
      EM.stop
    end
  end

  it "should create a crediential when binding" do
    EM.run do
      binding = @node.bind(@cassandraer["name"], @default_opts)
      binding["port"].should be 5002
      EM.stop
    end
  end

  it "should supply different credentials when binding evoked with the same input" do
    EM.run do
      binding1 = @node.bind(@cassandraer["name"], @default_opts)
      binding2 = @node.bind(@cassandraer["name"], @default_opts)
      binding1.should_not be binding2
      EM.stop
    end
  end

  it "shoulde delete crediential after unbinding" do
    EM.run do
      binding = @node.bind(@cassandraer["name"], @default_opts)
      @node.unbind(binding)
      EM.stop
    end
  end

  after :each do
    name = @cassandraer["name"]
    @node.unprovision(name)
  end
end
