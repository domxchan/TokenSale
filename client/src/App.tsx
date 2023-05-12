import { useState, useEffect } from 'react';
import './App.css';
import { contractAbi, contractAddress } from './lib/constant';
import { ethers } from 'ethers';
import Login from './components/Login';

const getFreeTeeTokenContract = () => {
  const { ethereum } = window;
  const provider = new ethers.providers.Web3Provider(ethereum);
  const signer = provider.getSigner();
  const contract = new ethers.Contract(contractAddress, contractAbi, signer);
  return contract;
}

function App() {
  const [currentAccount, setCurrentAccount] = useState();
  const [currentBalance, setCurrentBalance] = useState("");

  const connectWallet = async () => {
    const { ethereum } = window;
    if (ethereum) {
      const accounts = await ethereum.request({
        method: 'eth_requestAccounts',
      });
      setCurrentAccount(accounts[0]);
    } else {
      return alert('Please install metamask wallet');
    }
  };

  const getCurrentBalance = async () => {
    const balance = await getFreeTeeTokenContract().balanceOf(currentAccount);
    const sym = await getFreeTeeTokenContract().symbol();
    const result = ethers.utils.formatEther(balance) + ' ' + sym;
    setCurrentBalance(result);
  }

  useEffect(() => {
    getCurrentBalance()
  }, [])

  return (
    <div className="App">
      {currentAccount ? (
        <>
          <div className='navbar'>
            <p>wallet address: {currentAccount}</p>
          </div>
          <div className='header'>
            <div className='container'>
              <h1>{currentBalance}</h1>
              <button onClick={getCurrentBalance}>Get Balance</button>
            </div>
          </div>
        </>
      ) : (
        <Login connectWallet={ connectWallet }/>
      )}
    </div>
  );
}

export default App;
