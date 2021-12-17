creator: public(address)
number_of_recipients_to_receive: public(int128)
number_of_recipients_received: public(int128)
message: public(String[128])
recipients: public(HashMap[address, uint256])
completed: public(bool)


# Testnet--
celo_erc20_address: constant(address) = 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9

owner: constant(address) = 0xc7c1f793E9441e0abB593f0540a98c36d0b7Eb6E

# 0.2 celo!
minimum_packet_value: constant(uint256) = 200000000000000000

max_number_of_recipients_to_receive: constant(int128) = 10




event PacketReceived:
	_value: uint256
	_gas_x_2: uint256
	_address: address





@payable
@external
def __init__(
	_number_of_recipients_to_receive: int128,
	_message: String[128],
):
	# --
	assert msg.value >= minimum_packet_value, 'Not enough CELO sent to this contract!'
	assert _number_of_recipients_to_receive <= max_number_of_recipients_to_receive, 'Too many recipients!'

	self.creator = msg.sender
	self.number_of_recipients_to_receive = _number_of_recipients_to_receive
	self.message = _message

	# self.amount = msg.value



@external
def receive_packet(
	_address: address,
	_estimated_gas: uint256,
) -> bool:
	# --

	assert msg.sender == owner, 'You cannot do that!'
	assert self.number_of_recipients_to_receive != self.number_of_recipients_received, 'Already completed!'
	assert self.creator != msg.sender, 'Not your own packet!'


	a: uint256 = self.balance
	b: int128 = self.number_of_recipients_to_receive
	c: int128 = self.number_of_recipients_received


	value: uint256 = ((a / 3) * 2) - (_estimated_gas * 2)

	if (c - b) == 1:
		value = a - (_estimated_gas * 2)


	response_1: Bytes[32] = raw_call(
		celo_erc20_address,
		concat(
			method_id("transfer(address,uint256)"),
			convert(_address, bytes32),
			convert(value, bytes32),
		),
		max_outsize=32,
	)

	if len(response_1) != 0:
		assert convert(response_1, bool)


	response_2: Bytes[32] = raw_call(
		celo_erc20_address,
		concat(
			method_id("transfer(address,uint256)"),
			convert(owner, bytes32),
			convert((_estimated_gas * 2), bytes32),
		),
		max_outsize=32,
	)

	if len(response_2) != 0:
		assert convert(response_2, bool)

	log PacketReceived(value, _estimated_gas, _address)

	# msg.gas ...

	return True




# A selfdestruct function

