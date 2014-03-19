class Ggi

  def self.env
    @env ||= ENV['GGI_ENV'] ? ENV['GGI_ENV'] : 'development'
  end

end
