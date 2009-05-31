module FileHelpers
  def FileHelpers.sanitize_filename(filename)
    just_filename = File.basename(filename)
    just_filename.gsub(/[^\w\.\-]/,'_')
  end
end