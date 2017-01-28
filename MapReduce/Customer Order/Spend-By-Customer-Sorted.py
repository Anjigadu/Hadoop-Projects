from mrjob.job import MRJob
from mrjob.step import MRStep

class SpendByCustomerSorted(MRJob):
    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_orders,
                   reducer=self.reducer_totals_by_customer),
            MRStep(mapper=self.mapper_make_amounts_key,
                   reducer=self.reducer_output_results)
        ]
    def mapper_get_orders(self, _, line):
        (customerID, itemID, orderAmount) = line.split(',')
        yield customerID, float(orderAmount)

    def reducer_totals_by_customer(self, customerID, orders):
        yield customerID, sum(orders)

    def mapper_make_amounts_key(self, customerID, orderTotal):
        yield '%04.02f'%float(orderTotal), customerID
        
    def reducer_output_results(self, orderTotal, customerIDs):
        for customerID in customerIDs:
            yield customerID, orderTotal

if __name__ == '__main__':
    SpendByCustomerSorted.run()

# Output
"92"	"5379.28"
"6"	"5397.88"
"15"	"5413.51"
"63"	"5415.15"
"58"	"5437.73"
"32"	"5496.05"
"61"	"5497.48"
"85"	"5503.43"
"8"	"5517.24"
"0"	"5524.95"
"41"	"5637.62"
