<script lang="ts" setup>
import { makeWeb3 } from '@/utils/web3_utils'
import { ref, onMounted, Ref, computed } from 'vue'
import axios from "axios";


import Web3 from 'web3'
import { AbiItem } from 'web3-utils'
import Abi from './abi.json'


const NFT_CONTRACT_ADDRESS = "0x792F4684277F56d297b1b95308dd95332417e0CE";


const web3: Web3 = makeWeb3()
const MyNFTContract = new web3.eth.Contract(Abi as AbiItem[], NFT_CONTRACT_ADDRESS)
const mintCostEther = ref(".0001")
let mintNum = ref(1)
const totalMintCostEther = computed(() => (parseFloat(mintCostEther.value) * mintNum.value).toFixed(mintCostEther.value.length - 1).toString())

// check if MetaMask installed
console.log((window as any).ethereum)
const metamaskInstalled = ref(typeof (window as any).ethereum !== 'undefined')
console.log(`MetaMask is ${metamaskInstalled.value ? '' : 'NOT '}installed.`)

let displayAddress = ref(web3.eth.defaultAccount)
let errorMsg = ref('')

interface TokenMetadata {
    name: string;
    description: string;
    attribute: string;
    image: string;
}

interface TokenInfo {
    id: number;
    uri: string;
    metadata: any;
}

let tokenInfos: Ref<TokenInfo[]> = ref([])
let tokensOwned: Ref<number[]> = ref([])
let tokenURIs: Ref<string[]> = ref([])
let tokenImageURLs: Ref<string[]> = ref([])

// Connect
async function getDefaultAccount() {
    let accounts = await web3.eth.getAccounts()
    return accounts[0]
}

async function isMetaMaskConnected() {
  let accounts = await web3.eth.getAccounts()
  return accounts.length > 0
}

async function updateMetaMaskStatus() {
    console.debug("updateMetaMaskStatus()")
    await isMetaMaskConnected()
    displayAddress.value = await getDefaultAccount()
}

async function connectMetaMask() {
    await (window as any).ethereum
        .request({ method: 'eth_requestAccounts' })
        .then((result: any) => {
            if (displayAddress.value?.toLowerCase() !== result[0]) {
                displayAddress.value = result[0]
            }
            console.log(`Connected: ${displayAddress.value}`)
        })
        .catch((error: any) => {
            errorMsg.value = error.message
            console.error(errorMsg)
        })
    await updateMetaMaskStatus()
}

async function mint() {
    const methodCall = MyNFTContract.methods.awardItem(mintNum.value)
    const params = {
        from: (web3.currentProvider as any).selectedAddress,
        value: web3.utils.toWei(totalMintCostEther.value, 'ether')
    }

    // estimate gas
//    methodCall.estimat

    // call

    methodCall.send(params)
        .on('transactionHash', function(hash: any){
            console.log(`transactionHash: ${hash}`)
        })
        .on('receipt', function(receipt: any){
            console.log("receipt:")
            console.log(receipt)
        })
        .on('confirmation', function(confirmationNumber: any, receipt: any){
            console.log("confirmationNumber:")
            console.log(confirmationNumber)
        })
        .on('error', function(error: any, receipt: any) {
            console.error("error:")
            console.error(error)
        });
}

async function renderTokens() {
    const addr = (web3.currentProvider as any).selectedAddress
    const ctTokensOwned = await MyNFTContract.methods.balanceOf(addr).call().then((r: any) => {
        return r
    })
    console.log(`Address ${addr} owns ${ctTokensOwned} token${ctTokensOwned > 1 ? "s" : ""}`)

    // get and sort tokens owned
    tokenInfos.value = []
    tokensOwned.value = []
    tokenURIs.value = []
    tokenImageURLs.value = []
    for (let i = 0; i < ctTokensOwned; i++) {
        // address owned token index => token id
        const tokenId = await MyNFTContract.methods.tokenOfOwnerByIndex(addr, i).call().then((r: any) => {
            return r
        })
        tokensOwned.value.push(tokenId)
    }
    tokensOwned.value.sort()

    // pull details
    for (let i = 0; i < tokensOwned.value.length; i++) {
        const tokenId = tokensOwned.value[i]
        // token id => token URI
        const tokenURI = await MyNFTContract.methods.tokenURI(tokenId).call().then((r: any) => {
            console.log(`[${i}] ${r}`)
            return r
        })
        if (tokenURI.startsWith("data:application/json;base64")) {
            console.log("Decoding base64 via axios...")
        }


        // token URI => metadata
        let res: any = await axios.get(tokenURI);
        const metadata: any = res.data
        console.log("metadata:")
        console.log(metadata)
        console.log(metadata.image)

        tokenURIs.value.push(tokenURI)
        tokenImageURLs.value.push(metadata.image)
        tokenInfos.value.push({
            id: tokenId,
            uri: tokenURI,
            metadata: metadata
        })
    }
}

async function periodicRefresh() {
    if (await isMetaMaskConnected()) {
        const address = await getDefaultAccount()
        if (displayAddress.value !== address) {
            console.log(`Switched account: ${address}`)
            displayAddress.value = address;
            await renderTokens()
        }

    }

    setTimeout(periodicRefresh, 100)
}

onMounted(async () => {
    await updateMetaMaskStatus()
    await renderTokens()
    setTimeout(periodicRefresh, 100)
});
</script>

<template>
  <div>
    <h1>NFT</h1>
    <main>
      <ul class="summary">
        <li>
          <label>
            {{ metamaskInstalled ? '✅ ' : '❌' }} MetaMask
            {{ metamaskInstalled ? '' : 'NOT' }} Installed
          </label>
        </li>
        <li class="address">
            Address: {{ displayAddress !== "" ? displayAddress : "<disconnected>" }}
        </li>
        <li v-if="errorMsg !== ''" class="error">
          {{ errorMsg }}
        </li>
      </ul>
      <ul class="mint">
        <li>
          <button @click="connectMetaMask">Connect</button>
        </li>
        <li>
          <button @click="mint">Mint</button>
          <input v-model.number="mintNum" type="number" />
          <div>Cost: {{totalMintCostEther}}ETH</div>
        </li>
      </ul>
      <div class="wallet">
          <h2>Wallet</h2>
        <ul class="gallery">
            <li v-for="t in tokenInfos" :key="'tokenId=' + t.id">
                <div class="card">
                    <a :href="'https://testnets.opensea.io/assets/'+NFT_CONTRACT_ADDRESS+'/'+t.id" target="_blank">
                        <img :src="t.metadata.image" width="300" />
                    </a>
                    <label>{{t.metadata.name}}</label>
                </div>
            </li>
        </ul>
      </div>
      <div class="marketplace" v-if="true">
          <h2>Marketplace</h2>
            <iframe src='https://testnets.opensea.io/collection/mynft-colored-numbers?embed=true'
                width='100%'
                height='100%'
                frameborder='0'
                allowfullscreen></iframe>
      </div>
    </main>
  </div>
</template>

<style lang="scss">
main {
  border: 1px solid red;
  margin: 0 auto;
  padding: 0;
  width: 80%;
  height: 100%;


  ul.summary li:not(:last-child), ul.mint:not(:last-child) {
        margin: 0 0 2em 0;
    }
  ul {
    list-style: none;
    border: 1px solid blue;
    padding: 0;

    li {
      display: flex;
      flex-direction: row;
      margin: 0;

      button {
        margin-right: 2em;
      }

      label {
        margin-right: 1em;
      }
    }

    li.error {
      color: red;
    }
  }
     input[type=number]::-webkit-inner-spin-button,
input[type=number]::-webkit-outer-spin-button {

   opacity: 1;

}

  .mint {
      input {
          margin: 0 1em 0 0;
          width: 50px;
      }
  }

  .wallet {
    ul.gallery {
      display: flex;
      flex: row;
      flex-wrap: wrap;

      .card {
        align-items: center;
        border: 1px solid #ccc;
        display: flex;
        flex-direction: column;
        height: auto;
        width: 100%;

        a {
          display: relative;
          top: 0;
          left: 0;
          height: 100%;
          width: 100%;
        }

        label {
          font-weight: bold;
          margin: 0.5em auto
        }
      }
    }
  }



    .marketplace {
        height: 600px;
        width: 100%;
    }
}
</style>
