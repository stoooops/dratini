import Web3 from "web3";

// some credit to https://ethereum.stackexchange.com/a/17494
export function makeWeb3(): Web3 {
  // check installed
  if (typeof (window as any).ethereum === "undefined") {
    const msg = "Please use a web3 browser";
    console.error(msg);
    throw msg;
  } else {
    const web3 = new Web3((window as any).ethereum);

    return web3;
  }
}
