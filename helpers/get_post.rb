def self.get_post(url, &block)
  get url, &block
  post url, &block
end

