require 'time'
require_relative 'spec_helper'

describe "Trip class" do

  before do
    start_time = Time.parse('2015-05-20T12:14:00+00:00')
    end_time = Time.parse('2015-05-20T13:20:00+00:00')
    @trip_data = {
      id: 8,
      driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
      passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
      start_time: start_time,
      end_time: end_time,
      cost: 23.45,
      rating: 3
    }
    @trip = RideShare::Trip.new(@trip_data)
  end

  describe "initialize" do

    it "is an instance of Trip" do
      @trip.must_be_kind_of RideShare::Trip
    end

    it "stores an instance of passenger" do
      @trip.passenger.must_be_kind_of RideShare::Passenger
    end

    it "stores an instance of driver" do
      @trip.driver.must_be_kind_of RideShare::Driver
    end

    it "raises an error for an invalid rating" do
      [-3, 0, 6].each do |rating|
        @trip_data[:rating] = rating
        proc {
          RideShare::Trip.new(@trip_data)
        }.must_raise ArgumentError
      end
    end
    it "raises an error if the start-time comes after the end-time" do
      start_time_2 = Time.parse('2015-05-20T12:14:00+00:00')
      end_time_2 = start_time_2 - 25 * 60 # (minus 25 minutes)
      @trip_data_2 = {
        id: 8,
        driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
        start_time: start_time_2,
        end_time: end_time_2,
        cost: 23.45,
        rating: 3
      }
      proc {
      @trip_2 = RideShare::Trip.new(@trip_data_2)
          }.must_raise ArgumentError
    end
  end
  describe "report_trip_duration" do
    # Please see the comment in the method production code about
    # why this is here.  Executive summary: I made up a requirement
    # that didn't actually exist.
    it "reports the hours, minutes, and seconds in a trip in a readable string." do
      @trip.report_trip_duration.must_equal "1 hour(s), 6 minute(s), 0 second(s)."
    end
  end
end
