# version 0.4.0
# Licence

owner : public(address)
name: public(string[100])
expireAt: public(uint256)

@deploy
def __init__(_name: string[100], _expireTime uint256):
    self.owner = msg.sender
    self.name = _name
    self.expireAt = block.timstamp + _expireTime


@view
@external
def look() -> address, uint256, string:
    return self.owner
    return self.name
    return self.expireAt
    



    
