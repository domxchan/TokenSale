# 1. run foundry command: anvil

# 2. deploy FreeTeeToken contract with FreeTeeTokenSale contract (or deploy FreeTeeTokenSale separately)
forge script script/FreeTeeToken.s.sol:FreeTeeTokenScript --fork-url http://localhost:8545 --broadcast

# 2A. (if deploy FreeTeeTokenSale separately)
# get the token address, e.g. 0x5fbdb2315678afecb367f032d93f642f64180aa3
# get the checksum address, e.g. 0x5FbDB2315678afecb367f032d93F642f64180aa3
cast --to-checksum-address {address of token obtained from previous command}

# insert the checksum address to the constant TOKENADDR in the FreeTeeTokenSale.s.sol file
forge script script/FreeTeeTokenSale.s.sol:FreeTeeTokenSaleScript --fork-url http://localhost:8545 --broadcast
# get the FreeTeeTokenSale contract address


# 3. send some money from account[0] on foundry's anvil local blockchain to my own Metamask account
cast send --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --value 1ether 0x3fAba54796D00dB6d34900977C8E9C9Ed926452b
# check sender balance is decreased
cast balance 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
# check receiver balance is increased
cast balance 0x3fAba54796D00dB6d34900977C8E9C9Ed926452b

# 4. send some eth to the FreeTeeTokenSale contract 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
# using Metamask, this should convert into FreeTeeTokens
# To clear MetaMask's transaction queue and reset its nonce calculation, go 
# to Settings > Advanced and select Reset account.

# 5. check balance of token
# cast call {token address} "balanceOf(address)" 0x3fAba54796D00dB6d34900977C8E9C9Ed926452b
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "balanceOf(address)" 0x3fAba54796D00dB6d34900977C8E9C9Ed926452b

# convert result to decimal
# cast --to-base {result} 10
cast --to-base 0x00000000000000000000000000000000000000000000000000000000000004d2 10

