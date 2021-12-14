from vyper.interfaces import ERC20
# from vyper.interfaces import ERC721


# --
celo_gold_token_erc20_address: constant(address) = 0x6D0081857009Cb79014Df13E34FC49192F66AeE1



@external
def create_packet_drop(
	# _number_of_recipients_to_receive: int128,
	_amount_wei: uint256,
	# _message: bytes32,
):
	# --
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


