require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Stat" do
  def new_stat
    @stat = Stat.new(:start_date => "2008-12-25", :stop_date => "2008-12-31")
  end

  describe "validations" do
    before(:each) do
      @valid_attributes = {
        :start => 1.hour.ago,
        :stop => 1.hour.from_now,
        :view_by => 'day'
      }
    end

    it "should create a new instance given valid attributes" do
      Stat.create!(@valid_attributes)
    end

    it "should have errors start and stop if not presence" do
      @stat = Stat.new
      @stat.should have(1).error_on(:start)
      @stat.should have(1).error_on(:stop)
    end

  end

  describe ".start_date and .stop_date virtual attributes" do
    it "should create start properly by receiving start_date" do
      @stat = Stat.new(:start_date => Date.today.to_s)
      @stat.start.should == Date.today.to_time
    end

    it "should create stop properly by receiving stop_date" do
      @stat = Stat.new :stop_date => "12/31/2008"
      @stat.stop.should == Time.parse("12/31/2008")

    end
  end

  describe "loading fixtures" do
    fixtures :shifts, :shift_reports

    it "should load shifts correctly from fixtures" do
      @shift1 = shifts(:late_1)
      @shift1.user_id.should == 9
      @shift1.location_id.should == 1
      @shift1.shift_report.login_ip.should == "130.132.182.16"

      @stat = Stat.new(:start => Time.parse("2008-12-25 12:00:00"), :stop => Time.parse("2008-12-31 12:00:00"))
      @stat.shifts.size.should == 4
    end
  end

  describe "find shifts methods" do
    fixtures :shifts, :shift_reports, :locations, :location_groups, :departments, :shift_configurations
    before(:each) do
      new_stat
    end

    it "should calculate coverage correctly" do

      Stat.actual_vs_scheduled(@stat.shifts).should == Rational(4.hours + 45.minutes,7.hours) # there may be floating point problem but works for now
    end

    it "should calculate missed_shifts" do
      missed_shifts = Stat.filter_missed(@stat.shifts)
      missed_shifts.first.should ===(shifts(:missed_1))
      missed_shifts.size.should == 1
    end

    it "should find late grace period for a shift correctly from fixtures" do
      @shift = shifts(:late_1)
      (@shift.end_of_grace-@shift.start).should == 7.minutes
    end

    it "should caculate late_shifts correctly" do
      late_shifts = Stat.filter_late(@stat.shifts)
      late_shifts.size.should == 3 #remember department 2 has grace period of 0
    end

  end

  describe ".filter_by methods" do
    before(:each) do
      new_stat
    end

    it "should filter user_ids correctly when separate" do
      @stat.user_ids = "8, 9"
      @stat.shifts.size.should == 3
    end

    it "should filter location_ids correctly when separate" do
      @stat.location_ids = "1, 3"
      @stat.shifts.size.should == 2
    end

    it "should filter both user_ids and location_ids correctly when together" do
      @stat.user_ids = "8,9"
      @stat.location_ids = "1,2"
      @stat.shifts.size.should == 2
    end

    it "should filter location_group_ids correctly when separate" do
      @stat.location_group_ids = "1"
      @stat.shifts.size.should == 3
    end

    it "should filter department correctly when separate" do
      @stat.department_ids = "2"
      @stat.shifts.size.should == 1
    end

    it "should reset and recalculate properly if reset is called" do
      @stat.department_ids = "2"
      @stat.shifts.size.should == 1

      @stat.department_ids = nil
      @stat.shifts.size.should == 1 # same result unless reset is called
      @stat.department_ids = ""
      @stat.user_ids = "8,9"
      @stat.location_ids = "1,2"
      @stat.shifts(true).size.should == 2
    end

  end

  describe ".split_to_days" do
    before do
      new_stat
    end

    it "should have shift start date by days" do
      @stat.view_by = "day"
      shifts = @stat.split_to_view
      expected = [0,0,0,0,3,1]
      (@stat.start_date...@stat.stop_date).each_with_index do |day,i|
        (shifts[day.to_time]||[]).size.should == expected[i]
      end

    end

  end

  describe ".split_to_users/locations/location_groups" do
    fixtures :shifts, :shift_reports, :locations, :location_groups, :departments, :shift_configurations
    before do
      new_stat
    end
    it "should split to users correctly" do
      @stat.user_ids = "7,8,9"
      list = Stat.split_to_users(@stat.shifts)
      list.keys.sort.should == [7,8,9]
      list[7].class.should == Array
      list[8].class.should == Array
      list[9].class.should == Array
    end
    it "should split to locations correctly" do
      @stat.location_ids = "1,3"
      list = Stat.split_to_locations(@stat.shifts)
      list.keys.sort.should == [1,3]
    end
    it "should split to location_groups correctly" do
      @stat.location_group_ids = "1"
      list = Stat.split_to_location_groups(@stat.shifts)
      list.keys.sort.should == [1]
    end
  end


end
