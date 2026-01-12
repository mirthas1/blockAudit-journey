# pragma version 0.4.0
# @Licence 

my_favourite_number: public(uint256)

@external
def MFNum(new_number: uint256):
    self.my_favourite_number = new_number