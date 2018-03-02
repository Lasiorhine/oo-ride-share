require 'csv'
require 'time'

require_relative 'driver'
require_relative 'passenger'
require_relative 'trip'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize
      @drivers = load_drivers
      @passengers = load_passengers
      @trips = load_trips
    end

    def load_drivers
      my_file = CSV.open('support/drivers.csv', headers: true)

      all_drivers = []
      my_file.each do |line|
        input_data = {}
        # Set to a default value
        vin = line[2].length == 17 ? line[2] : "0" * 17

        # Status logic
        status = line[3]
        status = status.to_sym

        input_data[:vin] = vin
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:status] = status
        all_drivers << Driver.new(input_data)
      end

      return all_drivers
    end

    def find_driver(id)
      check_id(id)
      @drivers.find{ |driver| driver.id == id }
    end

    def load_passengers
      passengers = []

      CSV.read('support/passengers.csv', headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        passengers << Passenger.new(input_data)
      end

      return passengers
    end

    def find_passenger(id)
      check_id(id)
      @passengers.find{ |passenger| passenger.id == id }
    end

    def load_trips
      trips = []
      trip_data = CSV.open('support/trips.csv', 'r', headers: true, header_converters: :symbol)

      trip_data.each do |raw_trip|
        driver = find_driver(raw_trip[:driver_id].to_i)
        passenger = find_passenger(raw_trip[:passenger_id].to_i)
        start_time = Time.parse(raw_trip[:start_time])
        end_time = Time.parse(raw_trip[:end_time])

        parsed_trip = {
          id: raw_trip[:id].to_i,
          driver: driver,
          passenger: passenger,
          start_time: start_time,
          end_time: end_time,
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i
        }

        trip = Trip.new(parsed_trip)
        driver.add_trip(trip)
        passenger.add_trip(trip)
        trips << trip
      end
      trips
    end
    def find_first_available_driver
      @drivers.find { |driver|
        driver.status == :AVAILABLE
    }
    end

    def create_new_trip_id
      new_trip_id = (@trips.map(&:id).max + 1)
    end

    def request_trip(passenger_id)
      new_trip_data = {
        id: create_new_trip_id,
        driver: find_first_available_driver,
        passenger: find_passenger(passenger_id),
        start_time: Time.now,
        end_time: nil,
        cost: nil,
        rating: nil,
      }

      new_trip = RideShare::Trip.new(new_trip_data)
      @trips << new_trip
      return new_trip
=begin

PSEUDOCODE FOR (I), above:

  1. Identify a driver instance by :AVAILABLE
      .find
  2. Create a new instance of Trip, populated with:
      -the customer with the passed-in ID
      -the driver you found
      -a start_time of now
      -a :trip_id that is one more than the highest one you can find.
          .max_by
      -an end-time of nil
      -a cost of nil
      -a rating of nil
  3. Add the trip to TripDispatch's trips
  4. Call .driver_helper to do the stuff in II
  5. Call .passenger_helper to do the stuff in III

=end
    end




    def inspect

      "#<#{self.class.name}:0x#{self.object_id.to_s(16)}>"
    end

    private

    def check_id(id)
      if id == nil || id <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero. (got #{id})")
      end
    end
  end
end
