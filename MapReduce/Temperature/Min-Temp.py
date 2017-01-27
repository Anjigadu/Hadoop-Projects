# Find Temperature Extremes
# Data: weather station, date, temperature type, temperature
from mrjob.job import MRJob

class MRMinTemperature(MRJob):

    def MakeFahrenheit(self, tenthsOfCelsius):
        celsius = float(tenthsOfCelsius) / 10.0
        fahrenheit = celsius * 1.8 + 32.0
        return fahrenheit

    def mapper(self, _, line):
        (location, date, type, data, x, y, z, w) = line.split(',')
        if (type == 'TMIN'):
            temperature = self.MakeFahrenheit(data)
            yield location, temperature

    def reducer(self, location, temps):
        yield location, min(temps)


if __name__ == '__main__':
    MRMinTemperature.run()

# Execute file
# python Min-Temp.py temperature.csv

# Output
"EZE00100082"	7.699999999999999
"ITE00100554"	5.359999999999999
