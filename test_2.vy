from vyper.interfaces import ERC20
# from vyper.interfaces import ERC721


# --


# Transfer: event({_from: indexed(address), _to: indexed(address), _value: num256})
# Approval: event({_owner: indexed(address), _spender: indexed(address), _value: num256})



# struct PacketDropRecipient:
# 	has_received: bool
# 	amount_wei_received: uint256
# 	# packet_drop_



struct PacketDrop:
	sender: address
	amount_wei: uint256
	number_of_recipients_to_receive: int128
	number_of_recipients_has_received: int128
	amount_wei_sent_to_recipients: uint256
	message: bytes32
	recipients_addresses: address[10]
	recipients_values: uint256[10]
	recipients_block_numbers: uint256[10]

	# 

	# recipients: HashMap[address, PacketDropRecipient]
	

packet_drops_index: int128


# packet_drop_recipients_index: int128


packet_drops: HashMap[int128, PacketDrop]


# packet_drop_recipients: HashMap[int128, HashMap[int128, PacketDropRecipient]]
# _roles: HashMap[bytes32, HashMap[address, bool]]
# _admin_roles: HashMap[bytes32, bytes32]



celo_gold_token_erc20_address: constant(address) = 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9


# celo_gold_token_erc20_address: constant(address) = 0x67c6829506DdF66Ed824Fd1cCC40665588Bc4631

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



# those view only functions to check if it is indeed a valid packet, it exists - and there are remaining!

# @view
# @external
# def check_packet_is_valid() -> String[16]:
# 	# --



# 	return concat("Hello ", Greeter(msg.sender).name())




@view
@external
def get_packet_drop_recipient_txns(
	_pdi: int128,
) -> PacketDrop:
	# --

	return self.packet_drops[_pdi]






@payable
@external
def create_packet_drop(
	_number_of_recipients_to_receive: int128,
	_message: bytes32,
) -> int128:
	# --

	assert _number_of_recipients_to_receive <= 10, 'Too many recipients set!'


	pdi: int128 = self.packet_drops_index


	self.packet_drops[pdi] = PacketDrop({
		sender: msg.sender,
		amount_wei: msg.value,
		number_of_recipients_to_receive: _number_of_recipients_to_receive,
		message: _message,
		number_of_recipients_has_received: 0,
		amount_wei_sent_to_recipients: 0,
		recipients_addresses: empty(address[10]),
		recipients_values: empty(uint256[10]),
		recipients_block_numbers: empty(uint256[10]),
	})


	self.packet_drops_index = pdi + 1


	return pdi



@internal
def _has_address_recieved_this_packet_drop(
	_recipients_addresses: address[10],
	_address: address,
) -> bool:
	# --
	for i in range(10):
		if _address == _recipients_addresses[i]:
			return True

	return False
	




@external
def receive_packet_drop(
	_pdi: int128,
) -> bool:
	# --

	assert self.packet_drops[_pdi].number_of_recipients_has_received < self.packet_drops[_pdi].number_of_recipients_to_receive, 'No more packets left for you!'

	assert not self._has_address_recieved_this_packet_drop(self.packet_drops[_pdi].recipients_addresses, msg.sender), 'You have already received!'


	# if self.packet_drops[_slug].number_of_recipients_to_receive - self.packet_drops[_slug].number_of_recipients_has_received == 1:
	# 	value: uint256 = self.packet_drops[_slug].amount_wei - self.packet_drops[_slug].amount_wei_sent_to_recipients

	# 	response: Bytes[32] = raw_call(
	# 		celo_gold_token_erc20_address,
	# 		concat(
	# 			method_id("transfer(address,uint256)"),
	# 			convert(msg.sender, bytes32),
	# 			convert(value, bytes32),
	# 		),
	# 		max_outsize=32,
	# 	)
	# 	if len(response) != 0:
	# 		assert convert(response, bool)

	# else:


	a: uint256 = self.packet_drops[_pdi].amount_wei
	b: uint256 = self.packet_drops[_pdi].amount_wei_sent_to_recipients
	# c: int128 = self.packet_drops[_slug].number_of_recipients_to_receive
	# d: int128 = self.packet_drops[_slug].number_of_recipients_has_received
	# value: uint256 = ((a - b) * 0.6)
	value: uint256 = ((a - b) / 3) * 2


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


	self.packet_drops[_pdi].recipients_addresses[self.packet_drops[_pdi].number_of_recipients_has_received] = msg.sender
	self.packet_drops[_pdi].recipients_values[self.packet_drops[_pdi].number_of_recipients_has_received] = value
	self.packet_drops[_pdi].recipients_block_numbers[self.packet_drops[_pdi].number_of_recipients_has_received] = block.number


	self.packet_drops[_pdi].number_of_recipients_has_received += 1
	self.packet_drops[_pdi].amount_wei_sent_to_recipients += value


	return True






