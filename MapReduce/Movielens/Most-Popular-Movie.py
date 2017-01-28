# [Sloution Structure]
# Step 1.
# user, movie, rating, timestamp
# 196   242     3       881250949
# 186   302     3       891717742
# Step 2. Mapper
# 242: 1   302:1  242:1  51:1
# Step 3. Group and Sort
# 242:1,1  51:1
# Step 4. Reducer
# None:(2,242)  None:(1,322)
# Step 5. Reducer2
# 2,242

from mrjob.job import MRJob
from mrjob.step import MRStep

class MostPopularMovie(MRJob):
    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_ratings,
                   reducer=self.reducer_count_ratings),
            MRStep(mapper=self.mapper_passthrough,
                   reducer = self.reducer_find_max)
        ]

    def mapper_get_ratings(self, _, line):
        (userID, movieID, rating, timestamp) = line.split('\t')
        yield movieID, 1

# This mapper does nothing; 
# it's just here to avoid a bug in some versions of mrjob related to "non-script steps." 
# Normally this wouldn't be needed.
    def mapper_passthrough(self, key, value):
        yield key, value

    def reducer_count_ratings(self, key, values):
        yield None, (sum(values), key)       # tuple

    def reducer_find_max(self, key, values):
        yield max(values)

if __name__ == '__main__':
    MostPopularMovie.run()
