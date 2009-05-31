class PeepCode
  def awesome?
    true
  end
  
  def screencasts
    ['RESTful Rails', 'Capistrano Concepts', 'TextMate for Rails']
  end
end

class Book
  
end
describe "PeepCode" do
  before(:each) do
    @peepcode = PeepCode.new
  end
  
  it do
    @peepcode.should be_awesome
    
  end
  
  it do
    @peepcode.should_not be_an_instance_of(Book)
    
  end
  
  it do
    @peepcode.should have(3).screencasts
  end
end