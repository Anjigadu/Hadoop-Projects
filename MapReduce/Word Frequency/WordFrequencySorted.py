# Make sorted key - the count
from mrjob.job import MRJob
from mrjob.step import MRStep
import re

WORD_REGEXP = re.compile(r"[\w']+")

class MRWordFrequencyCount(MRJob):

    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_words,
                   reducer=self.reducer_count_words),
            
            MRStep(mapper=self.mapper_make_counts_key,
                   reducer = self.reducer_output_words)
        ]

    def mapper_get_words(self, _, line):
        words = WORD_REGEXP.findall(line)
        for word in words:
            word = unicode(word, "utf-8", errors="ignore") #avoids issues in mrjob 5.0
            yield word.lower(), 1

    def reducer_count_words(self, word, value):
        yield word, sum(value)
    
    def mapper_make_counts_key(self, word, count):
        yield '%04d' %int(count), word                  # '%04d' 4's 0
        
    def reducer_output_words(self, count, words):
        for word in words:
            yield count, word


if __name__ == '__main__':
    MRWordFrequencyCount.run()

# Output
"0321"	"have"
"0334"	"i"
"0343"	"as"
"0354"	"can"
"0369"	"be"
"0382"	"business"
"0411"	"if"
"0424"	"are"
"0428"	"on"
"0496"	"it"
"0537"	"for"
"0560"	"is"
"0616"	"in"
