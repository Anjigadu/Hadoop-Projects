# Average number of friends by age
from mrjob.job import MRJob

class MRFriendsByAge(MRJob):

    def mapper(self, _, line):
        (ID, name, age, numFriends) = line.split(',')
        yield age, float(numFriends)

    def reducer(self, age, numFriends):
        total = 0
        numElements = 0
        for x in numFriends:
            total += x
            numElements += 1
            
        yield age, total / numElements


if __name__ == '__main__':
    MRFriendsByAge.run()

class MRFriendsByAge(MRJob):
    def mapper(self,):
        
    def reducer(self,age,numfriends):
        yield age,
        

    
    
    
    
    
    
# Execute the file
# python  friends_by_age.py fakefriends.csv


