# How much order amounts did each customer spend?
# Column: CUSTOMER, ITEM, ORDER AMOUNT
from mrjob.job import MRJob

class SpendByCustomer(MRJob):

    def mapper(self, _, line):
        (customerID, itemID, orderAmount) = line.split(',')
        yield customerID, float(orderAmount)

    def reducer(self, customerID, orderAmount):
        yield customerID, sum(orderAmount)


if __name__ == '__main__':
    SpendByCustomer.run()
    
# Output
"0"	5524.950000000002
"1"	4958.600000000001
"10"	4819.7
"11"	5152.29
"12"	4664.589999999999
"13"	4367.619999999999
"14"	4735.030000000001
"15"	5413.510000000001
"16"	4979.060000000001
"17"	5032.680000000001
"18"	4921.27
