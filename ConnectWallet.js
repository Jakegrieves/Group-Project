import { useState } from "react";
import { Button } from "antd";
import { Web3Provider } from '@ethersproject/providers'
const ethers = require("ethers");

export default function ConnectWallet(){
  const[isConnected,setIsConnect] = useState(false);
  const [provider,setProvider] = useState();

  async function connect(){
    if (typeof window.ethereum !== 'undefined'){
      try{
        await window.ethereum.request({method:"eth_requestAccounts"});
        setIsConnect(true);
        let connecetedProvider = new ethers.providers.Web3Provider(window.ethereum);
        setProvider(connecetedProvider.getSigner());
      }catch(e){
        console.log(e);
      }
    }else{
      setIsConnect(false);
    }
  }
  return (
    <div >
      <Button type="primary" onClick={() => connect()}>
        Connect Wallet
      </Button>
      
    </div>
  )
}
