module Textliner

  module ScopeProxy
    def self.included(base)
      # simple entry point to scope chain
      class << base 
        def scope(name, body)
          scopes[name] = body

          metaclass.define_method(name) do |*args|
            # first usage of scope begins the chain
            ScopeProxyWrapper.new(self).run_scope(name, *args)
          end
        end

        def scopes ; @scopes ||= {} ; end

        def metaclass
          class << self ; self ; end
        end
      end
    end
  end

  class ScopeProxyWrapper < BasicObject
    attr_accessor :target, :scope_opts

    delegate :scopes, to: :target
    
    def initialize(target)
      self.target = target
      self.scope_opts = {}
    end

    def scope?(name) ; scopes.key?(name) ; end

    # evaluated at runtime
    def run_scope(name, *args)
      push_opts(scopes[name].call(*args))
      self
    end

    def push_opts(opts)
      self.scope_opts = merge_opts(scope_opts, opts)
      self
    end

    def find(*args)
      new_args = args.dup

      new_args.push({}) unless new_args.last.is_a?(::Hash)

      old_opts = new_args.pop
         
      new_args.push(
        merge_opts(
          old_opts,
          scope_opts))

      target.find(*new_args)
    end

    def merge_opts(old_opts, new_opts)
      new_opts
        .reduce(old_opts) do |ac, pair|
          key, value = pair
          ac
            .merge(key => (
              ac[key] ?
                ac[key].merge(value) :
                value))
          end
    end

    def method_missing(meth_sym, *args, &block)
      scope?(meth_sym) ?
        run_scope(meth_sym, *args) :
        target.send(meth_sym, *args, &block)
    end
  end
end
