# pragma version 0.4.0
# Licence 

my_favourite_number: public(uint256)

@external
def store(new_number: uint256):
    self.my_favourite_number = new_number

@external 
@view
def retreve() -> uint256:
    return self.my_favourite_number

