import React from 'react';

interface Props {
    connectWallet: () => void
}

const Login = ({ connectWallet }: Props) => {
  return (
    <div>
      <h1>T-Shirt on Web3</h1>
      <button onClick={connectWallet}>Login Metamask</button>
    </div>
  );
};

export default Login;
