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
	recipients_txns: bytes32[10]
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
	pdi: int128,
) -> bytes32[10]:
	# --

	return self.packet_drops[pdi].recipients_txns






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
		recipients_txns: empty(bytes32[10]),
	})


	self.packet_drops_index = pdi + 1


	return pdi




@external
def receive_packet_drop(
	pdi: int128,
) -> bool:
	# --

	assert self.packet_drops[pdi].number_of_recipients_has_received < self.packet_drops[pdi].number_of_recipients_to_receive, 'No more packets left for you!'

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


	a: uint256 = self.packet_drops[pdi].amount_wei
	b: uint256 = self.packet_drops[pdi].amount_wei_sent_to_recipients
	# c: int128 = self.packet_drops[_slug].number_of_recipients_to_receive
	# d: int128 = self.packet_drops[_slug].number_of_recipients_has_received
	# value: uint256 = ((a - b) * 0.6)
	value: uint256 = ((a - b) / 2) * 3


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


	self.packet_drops[pdi].recipients_txns[self.packet_drops[pdi].number_of_recipients_has_received] = convert(response, bytes32)


	self.packet_drops[pdi].number_of_recipients_has_received += 1
	self.packet_drops[pdi].amount_wei_sent_to_recipients += value


	return True






