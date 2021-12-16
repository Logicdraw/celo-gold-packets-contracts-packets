from vyper.interfaces import ERC20
# from vyper.interfaces import ERC721


# --


# Transfer: event({_from: indexed(address), _to: indexed(address), _value: num256})
# Approval: event({_owner: indexed(address), _spender: indexed(address), _value: num256})



struct PacketDropRecipient:
	has_received: bool
	amount_wei_received: uint256



struct PacketDrop:
	sender: address
	amount_wei: uint256
	_timestamp: uint256
	number_of_recipients_to_receive: int128
	number_of_recipients_has_received: int128
	amount_wei_sent_to_recipients: uint256
	message: bytes32

	# recipients: HashMap[address, PacketDropRecipient]
	



packet_drops: HashMap[bytes32, PacketDrop]
packet_drop_recipients: HashMap[bytes32, PacketDropRecipient]
# _roles: HashMap[bytes32, HashMap[address, bool]]
# _admin_roles: HashMap[bytes32, bytes32]



celo_gold_token_erc20_address: constant(address) = 0x67c6829506DdF66Ed824Fd1cCC40665588Bc4631
# celo_gold_token_erc20_address: constant(address) = 0x6d0081857009cb79014df13e34fc49192f66aee1


# max_packet_drops_amount: public(int128)
# max_packet_drops_amount_wei: constant(uint256) = 10000000





@external
def __init__():
	# --
	pass



# @external
# @payable
# def __default__():
#     # log Payment(msg.value, msg.sender)
#     pass



@external
def create_packet_drop(
	_number_of_recipients_to_receive: int128,
	_amount_wei: uint256,
	_message: bytes32,
) -> bytes32:
	# --

	# set to allowance to 0 ?

	amount: uint256 = ERC20(celo_gold_token_erc20_address).balanceOf(msg.sender)
	allowance: uint256 = ERC20(celo_gold_token_erc20_address).allowance(msg.sender, self)
	

	if (allowance == 0):
		return False
	
	if (allowance < amount):
		return False
	
	else:
		if (allowance >= amount):
			ERC20(celo_gold_token_erc20_address).transferFrom(msg.sender,self,amount)
			# log balancex(amount)
			return True
		else:
			return False


	_slug: bytes32 = Random(0x67c6829506DdF66Ed824Fd1cCC40665588Bc4631).getBlockRandomness(block.number)


	# ERC20(celo_gold_token_erc20_address).transferFrom(msg.sender, self, _amount_wei)

	_timestamp: uint256 = block.timestamp
	# slug is wrong btw ...
	# concat, ...
	# slug: bytes32 = keccak256(concat(_timestamp))
	# slug: bytes32 = 0xb5c8bd9430b6cc87a0e2fe110ece6bf527fa4f170a4bc8cd032f768fc5219838

	self.packet_drops[_slug] = PacketDrop({
		sender: msg.sender,
		amount_wei: _amount_wei,
		_timestamp: _timestamp,
		number_of_recipients_to_receive: _number_of_recipients_to_receive,
		message: _message,
		number_of_recipients_has_received: 0,
		amount_wei_sent_to_recipients: 0,
	})


	return _slug



@external
def receive_packet_drop(
	_slug: bytes32,
) -> bool:
	# --

	assert self.packet_drops[_slug].number_of_recipients_has_received < self.packet_drops[_slug].number_of_recipients_to_receive, 'No more packets left for you!'

	# if self.packet_drops[_slug].number_of_recipients_to_receive - self.packet_drops[_slug].number_of_recipients_has_received > 1:
	# 	# formula:
	# 	a: uint256 = self.packet_drops[_slug].amount_wei
	# 	b: uint256 = self.packet_drops[_slug].amount_wei_sent_to_recipients
	# 	# c: int128 = self.packet_drops[_slug].number_of_recipients_to_receive
	# 	# d: int128 = self.packet_drops[_slug].number_of_recipients_has_received
	# 	# value: uint256 = ((a - b) * 0.6)
	# 	value: uint256 = (a - b)
	# 	# timestamp...

	# elif self.packet_drops[_slug].number_of_recipients_to_receive - self.packet_drops[_slug].number_of_recipients_has_received == 1:
	# 	# Last recipient!
	# 	value: uint256 = self.packet_drops[_slug].amount_wei - self.packet_drops[_slug].amount_wei_sent_to_recipients


	a: uint256 = self.packet_drops[_slug].amount_wei
	b: uint256 = self.packet_drops[_slug].amount_wei_sent_to_recipients
	# c: int128 = self.packet_drops[_slug].number_of_recipients_to_receive
	# d: int128 = self.packet_drops[_slug].number_of_recipients_has_received
	# value: uint256 = ((a - b) * 0.6)
	value: uint256 = (a - b)


	# recipient_slug: bytes32 = keccak256(concat(convert(_slug, bytes32), convert(msg.sender, bytes32)))
	# recipient_slug: bytes32 = 0xb5c8bd9430b6cc87a0e2fe110ece6bf527fa4f170a4bc8cd032f768fc5219838
	_recipient_slug: bytes32 = Random(0x67c6829506DdF66Ed824Fd1cCC40665588Bc4631).getBlockRandomness(block.number)


	self.packet_drop_recipients[_recipient_slug] = PacketDropRecipient({
		has_received: True,
		amount_wei_received: value,
	})

	self.packet_drops[_slug].number_of_recipients_has_received += 1
	self.packet_drops[_slug].amount_wei_sent_to_recipients += value


	response: Bytes[32] = raw_call(
		celo_gold_token_erc20_address,
		concat(
			method_id("transfer(address,uint256)"),
			convert(msg.sender, bytes32),
			convert(value, bytes32),
		),
		max_outsize=32,
	)
	if len(response) != 0:
		assert convert(response, bool)

	return True



