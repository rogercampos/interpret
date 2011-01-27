# Gist from: https://gist.github.com/745617
module LazyHash
  class << self
    def lazy_add(hash, key, value, pre = nil)
      skeys = key.split(".")
      f = skeys.shift
      if skeys.empty?
        pre.nil? ? hash.send("[]=", f, value) : pre.send("[]=", f, value)
      else
        pre = pre.nil? ? hash.send("[]", f) : pre.send("[]", f)
        lazy_add(hash, skeys.join("."), value, pre)
      end
    end

    def build_hash
      lazy = lambda { |h,k| h[k] = Hash.new(&lazy) }
      Hash.new(&lazy)
    end
  end
end

