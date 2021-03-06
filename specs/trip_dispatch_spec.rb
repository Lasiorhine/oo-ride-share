require 'time'
require 'pry'
require_relative 'spec_helper'


describe "TripDispatcher class" do

  before do

    unavailable_drivers = [
      # All names in this test data set beginwith "X", as do all vins, so as to distinguish this purpose-built dummy set from the production set. For the same reason, all driver ids are > 700.
      RideShare::Driver.new(id: 701, name: "Xernardo Xrosacco", vin: "XBWSS52P9NEYLVDE9", status: :UNAVAILABLE, trips: nil),

      RideShare::Driver.new(id: 702, name: "Xmory Xosenbaum", vin: "XB9WEX2R92R12900E", status: :UNAVAILABLE, trips: nil),

      RideShare::Driver.new(id: 703, name: "Xaryl Xitzsche", vin: "XAL6P2M2XNHC5Y656", status: :UNAVAILABLE, trips: nil),

      RideShare::Driver.new(id: 704, name: "Xeromy X'Keefe DVM", vin: "X1CKRVH55W8S6S9T1", status: :UNAVAILABLE, trips: nil),

      RideShare::Driver.new(id: 705, name: "Xerla Xarquardt", vin: "XAMLE35L3MAYRV1JD", status: :UNAVAILABLE, trips: nil)
    ]

    @dispatcher_1 = RideShare::TripDispatcher.new
    @dispatcher_2_unavail = RideShare::TripDispatcher.new
    @dispatcher_2_unavail.drivers = unavailable_drivers

    #Special stuff for testing methods involving drivers with ongoing trips:

    @a_trip_in_progress = RideShare::Trip.new({id: 901, driver: "Yinnie Yach", passenger: "passenger_TBD", start_time: Time.now, end_time: nil, cost: nil, rating: nil})

    @driver_y_in_progress = RideShare::Driver.new(id: 800, name: "Yinnie Yach", vin: "YF9Z0ST7X18WD41HT", status: :UNAVAILABLE, trips: @a_trip_in_progress)

  end

  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = RideShare::TripDispatcher.new
      [:trips, :passengers, :drivers].each do |prop|
        dispatcher.must_respond_to prop
      end

      dispatcher.trips.must_be_kind_of Array
      dispatcher.passengers.must_be_kind_of Array
      dispatcher.drivers.must_be_kind_of Array
    end
  end

  describe "find_driver method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_driver(0) }.must_raise ArgumentError
    end

    it "finds a driver instance" do
      driver = @dispatcher.find_driver(2)
      driver.must_be_kind_of RideShare::Driver
    end
  end

  describe "find_passenger method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
    end

    it "finds a passenger instance" do
      passenger = @dispatcher.find_passenger(2)
      passenger.must_be_kind_of RideShare::Passenger
    end
  end

  describe "loader methods" do
    it "accurately loads driver information into drivers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_driver = dispatcher.drivers.first
      last_driver = dispatcher.drivers.last

      first_driver.name.must_equal "Bernardo Prosacco"
      first_driver.id.must_equal 1
      first_driver.status.must_equal :UNAVAILABLE
      last_driver.name.must_equal "Minnie Dach"
      last_driver.id.must_equal 100
      last_driver.status.must_equal :AVAILABLE
    end

    it "accurately loads passenger information into passengers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_passenger = dispatcher.passengers.first
      last_passenger = dispatcher.passengers.last

      first_passenger.name.must_equal "Nina Hintz Sr."
      first_passenger.id.must_equal 1
      last_passenger.name.must_equal "Miss Isom Gleason"
      last_passenger.id.must_equal 300
    end

    it "accurately loads trip info and associates trips with drivers and passengers" do
      dispatcher = RideShare::TripDispatcher.new

      trip = dispatcher.trips.first
      driver = trip.driver
      passenger = trip.passenger
      start_time = trip.start_time
      end_time = trip.end_time

      driver.must_be_instance_of RideShare::Driver
      driver.trips.must_include trip
      passenger.must_be_instance_of RideShare::Passenger
      passenger.trips.must_include trip
      start_time.must_be_instance_of Time
      end_time.must_be_instance_of Time

    end
  end
  describe "choose_available_driver" do
    before do
      @chosen_driver = @dispatcher_1.choose_available_driver
    end

    it "identifies an available driver" do
      @chosen_driver.must_be_instance_of RideShare::Driver
      @chosen_driver.status.must_equal :AVAILABLE
    #   name = driver_to_assign.name
    #   name.must_equal "Emory Rosenbaum"
    end

    it "chooses the first driver who has not yet had a trip, if multiple drivers are available." do
      @chosen_driver.name.must_equal "Minnie Dach"
      @chosen_driver.id.must_equal 100
    end

    it "chooses the driver who has been idle the longest since the end of their most recent trip, if more than one driver is available" do

      @dispatcher_5_no_newbs = RideShare::TripDispatcher.new
      @dispatcher_5_no_newbs.drivers.delete_at(99)
      @non_newb_driver = @dispatcher_5_no_newbs.choose_available_driver

      #The following two assertions test the test:
      @dispatcher_5_no_newbs.drivers.count.must_equal 99
      @dispatcher_5_no_newbs.drivers.find { |driver| driver.name == "Minnie Datch"}.must_be_nil

      #The following assertions test the actual production code.
      @non_newb_driver.name.must_equal "Antwan Prosacco"
      @non_newb_driver.id.must_equal 14
    end

    it "will not choose a driver who has a trip in progress" do
      #Test arrangement:
      @dispatcher_3_only_in_prog = RideShare::TripDispatcher.new
      @dispatcher_3_only_in_prog.drivers = [@driver_y_in_progress]

      #The two assertions below just test the test:
      @dispatcher_3_only_in_prog.drivers.count.must_equal 1
      @dispatcher_3_only_in_prog.drivers.find { |driver| driver.id == 800}.wont_be_nil

      #The assertion below is the actual test of the production code:
      @dispatcher_3_only_in_prog.choose_available_driver.must_be_nil
    end

    it "returns nil when there are no drivers with available status" do
      #The two assertions below just test the test:
      @dispatcher_2_unavail.drivers.count.must_equal 5
      @dispatcher_2_unavail.drivers.find { |driver| driver.id == 701}.wont_be_nil
      #The assertion below is the actual test of the production code.
      @dispatcher_2_unavail.choose_available_driver.must_be_nil
    end

  end

  describe "create_new_trip_id" do

    it "creates a trip ID number that is one higher than the current highest trip ID number" do
      new_trip_id = @dispatcher_1.create_new_trip_id
      new_trip_id.must_be_kind_of Integer
      new_trip_id.to_i.must_equal 601
    end
  end

  describe "request_trip(passenger_id)" do

    before do
      @dispatcher_4 = RideShare::TripDispatcher.new
      @test_trip = @dispatcher_4.request_trip(232)
    end

    it "creates a new instance of Trip" do
      @test_trip.must_be_instance_of RideShare::Trip
    end

    it "gives the new trip the correct id" do
      @test_trip.id.must_equal 601
    end

    it "assigns the first available driver" do
      @test_trip.driver.name.must_equal "Minnie Dach"
    end

    it "assigns the passenger with the specified id" do
      @test_trip.passenger.name.must_equal "Creola Bernier PhD"
    end

    it "has an initial cost of nil" do
      @test_trip.cost.must_be_nil
    end

    it "has an initial rating of nil" do
      @test_trip.rating.must_be_nil
    end

    it "has an initial end-time of nil" do
      @test_trip.end_time.must_be_nil
    end

    it "has a start time of approximately the moment the ride was requested" do
      @test_trip.start_time.to_i.must_be_close_to Time.now.to_i, 5
    end

    it "adds the new trip to the TripDispatch's collection" do
      @dispatcher_4.trips.must_include @test_trip
      @dispatcher_4.trips.count.must_equal 601
    end

    it "adds the new trip to the driver's collection" do
      @test_trip.driver.trips.count.must_equal 1
      @test_trip.driver.trips.find { |trip| trip.id == 601 }.wont_be_nil
    end

    it "adds the new trip to the passenger's collection" do
      @test_trip.passenger.trips.count.must_equal 5
      @test_trip.passenger.trips.find { |trip| trip.id == 601 }.wont_be_nil
    end

    it "raises an error if there are no drivers with available status" do

      proc{ @dispatcher_2_unavail.request_trip(232)}.must_raise StandardError

    end
  end
end
