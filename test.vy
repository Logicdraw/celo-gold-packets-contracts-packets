from vyper.interfaces import ERC20
# from vyper.interfaces import ERC721


# 0x67c6829506DdF66Ed824Fd1cCC40665588Bc4631

interface Random():
	def random() -> bytes32: view
	def getBlockRandomness(block_number: uint256) -> bytes32: view



# --
celo_gold_token_erc20_address: constant(address) = 0x6D0081857009Cb79014Df13E34FC49192F66AeE1




@payable
@external
def __default__():
	# log.Payment(msg.value, msg.sender)
	pass



@external
def dumb():
	send(msg.sender, 10000000000000000)



# @payable
@external
def create_packet_drop(
	# _number_of_recipients_to_receive: int128,
	_amount_wei: uint256,
	# _message: bytes32,
) -> bool:
	# --

	rand: bytes32 = Random(0x67c6829506DdF66Ed824Fd1cCC40665588Bc4631).getBlockRandomness(block.number)

	# assert msg.value <= max_packet_drops_amount_wei, 'Too much value sent!'
	ERC20(celo_gold_token_erc20_address).transferFrom(msg.sender, self, _amount_wei)

	# timestamp: uint256 = block.timestamp
	# slug: bytes32 = keccak256(timestamp)

	# self.next_packet_drop_index[slug] = PacketDrop({
	# 	sender: msg.sender,
	# 	amount: msg.value,
	# 	timestamp: timestamp,
	# 	number_of_recipients_to_receive: _number_of_recipients_to_receive,
	# 	message: _message,
	# })


	# return slug
	return True




# works quite well :)
# maybe not payable ???
# @payable
@external
def receive_packet_drop(
	_amount: uint256,
	_address: address,
) -> bool:
	# --

	# amount: uint256 = ERC20(celo_gold_token_erc20_address).balanceOf(self)
	# amount: uint256 = 10
	response: Bytes[32] = raw_call(
		_address,
		concat(
			method_id("transfer(address,uint256)"),
			convert(msg.sender, bytes32),
			convert(_amount, bytes32),
		),
		max_outsize=32,
	)
	if len(response) != 0:
		assert convert(response, bool)

	return True








