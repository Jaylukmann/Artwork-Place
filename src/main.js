import Web3 from "web3"
import { newKitFromWeb3 } from "@celo/contractkit"
import BigNumber from "bignumber.js"
import artWorkPlaceAbi from "../contract/artWorkPlace.abi.json"
import erc20Abi from "../contract/erc20.abi.json"

const ERC20_DECIMALS = 18
const AWContractAddress = "0x60430C99a86a8F340792eABa01C74d03268D298C"
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"

let kit
let contract
let artwork = []

const connectCeloWallet = async function () {
  if (window.celo) {
    notification("⚠️Dapp waiting for approval .....")
    try {
      await window.celo.enable()
      notificationOff()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]

      contract = new kit.web3.eth.Contract(artWorkPlaceAbi, AWContractAddress)
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}

async function approve(_price) {
const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

  const result = await cUSDContract.methods
    .approve(AWContractAddress, _price)
    .send({ from: kit.defaultAccount })
  return result
}

const getBalance = async function () {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}

const getArtWork = async function() {
  const _artWorkLength = await contract.methods.getArtWorkLength().call()
  const _artworks = []
  for (let i = 0; i < _artWorkLength; i++) {
    let _artwork = new Promise(async (resolve, reject) => {
      let p = await contract.methods.viewArtWork(i).call()
      resolve({
        index: i,
        owner: p[0],
        name: p[1],
        image: p[2],
        shortHistory: p[3],
        origin: p[4],
        price: new BigNumber(p[5]),
        sold: p[6],
      })
    })
    _artworks.push(_artwork)
  }
  artwork = await Promise.all(_artworks)
  renderArtwork()
}

function renderArtwork() {
  document.getElementById("artworkplace").innerHTML = ""
  artwork.forEach((_artwork) => {
    const newDiv = document.createElement("div")
    newDiv.className = "col-md-4"
    if (_artwork.owner == "0x0000000000000000000000000000000000000000") return
    newDiv.innerHTML = artworkTemplate(_artwork)
    document.getElementById("artworkplace").appendChild(newDiv)
  })
}
function artworkTemplate(_artwork) {
  let configArtwork = ""
  if (kit.defaultAccount === _artwork.owner) {
        configArtwork = `     
        <button class="btn btn-primary" 
            data-bs-toggle="modal"
            data-bs-target="#editModal"
            data-index="${_artwork.index}"
            data-name="${_artwork.name}"
            data-image="${_artwork.image}"
            data-shortHistory="${_artwork.shortHistory}"
            data-origin="${_artwork.origin}"
            data-price="${_artwork.price.shiftedBy(-ERC20_DECIMALS)}"
            id=${
              _artwork.index
        }>
            <i class="bi bi-wrench "></i> Edit
        </button>
        <button class="btn btn-danger delBtn" id=${
          _artwork.index
        }>
            <i class="bi bi-trash"></i> 
            Delete
        </button>
        `
  }
  return `
    <div class="card mb-4">
      <div style="position:relative">
        <img class="card-img-top" src="${_artwork.image}" alt="...">
        <div style="position:absolute;right:0;bottom:0;">
        </div>
        `+ configArtwork +`
      </div>
      <div class="position-absolute top-0 end-0 bg-warning mt-4 px-2 py-1 rounded-start">
        ${_artwork.sold} Sold
      </div>
      <div class="card-body text-left p-4  pl-20 position-relative">
        <div class="translate-middle-y position-absolute top-0">
        ${identiconTemplate(_artwork.owner)}
        </div>
          <h2 class="card-title fs-4 fw-bold mt-2 flex-grow-1">${_artwork.name}</h2>
        <p class="card-text mb-4" style="min-height: 82px">
          ${_artwork.shortHistory}             
        </p>
        <p class="card-text mt-4">
          <i class="bi bi-geo-alt-fill"></i>
          <span>${_artwork.origin}</span>
        </p>
        <div class="d-grid gap-2">
            <a class="btn btn-lg btn-outline-primary buyBtn fs-6 p-3" id=${
              _artwork.index
            }>
                Buy for ${_artwork.price.shiftedBy(-ERC20_DECIMALS).toFixed(2)} cUSD
            </a>
        </div>
      </div>
    </div>
  `
}

function identiconTemplate(_address) {
  const icon = blockies
    .create({
      seed: _address,
      size: 8,
      scale: 16,
    })
    .toDataURL()

  return `
  <div class="rounded-circle overflow-hidden d-inline-block border border-white border-2 shadow-sm padding-top-20">
    <a href="https://alfajores-blockscout.celo-testnet.org/address/${_address}/transactions"
        target="_blank">
        <img src="${icon}" width="48" alt="${_address}">
    </a>
  </div>
  `
}

function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}

window.addEventListener("load", async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  await getArtWork()
  notificationOff()
});

document
  .querySelector("#newArtworkBtn")
  .addEventListener("click", async (e) => {
    const params = [
      document.getElementById("newArtworkName").value,
      document.getElementById("newImgUrl").value,
      document.getElementById("newArtworkShortHistory").value,
      document.getElementById("newOrigin").value,
      new BigNumber(document.getElementById("newPrice").value)
      .shiftedBy(ERC20_DECIMALS)
      .toString()
    ]
    notification(`⌛ Adding "${params[0]}"...`)
    try {
      const result = await contract.methods
        .createArtWork(...params)
        .send({ from: kit.defaultAccount })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 You successfully added ${params[0]} at 5% discount.`)
    getArtWork()
  })

  document.querySelector("#artworkplace").addEventListener("click", async (e) => {
    if (e.target.className.includes("buyBtn")) {
      const index = e.target.id
      notification("⌛ Waiting for payment approval...")
      try {
        await approve(artwork[index].price)
      } catch (error) {
        notification(`⚠️ ${error}.`)
      }
      notification(`⌛ Awaiting payment for "${artwork[index].name}"...`)
      try {
        const result = await contract.methods
          .buyArtWork(index)
          .send({ from: kit.defaultAccount })
        notification(`🎉 You successfully bought "${artwork[index].name}".`)
        getArtWork()
        getBalance()
      } catch (error) {
        notification(`⚠️ ${error}.`)
      }
    }
  })  
  document.querySelector("#artworkplace").addEventListener("click", async (e) => {
  if (e.target.className.includes("delBtn")) {
    const index = e.target.id
    notification(`🎉 Removing "${artwork[index].name}"...`)
    try {
      const result =  await contract.methods
        .removeArtwork(index)
        .send({ from: kit.defaultAccount })
      getArtWork()
      getBalance()
      
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 Successfully removed "${artwork[index].name}"...`)
  }
  })

    document.querySelector("#editArtwork").addEventListener("click", async (e) => {
      const index = document.getElementById('editArtwork').getAttribute('data-index')
      const name = document.getElementById("editArtworkName").value
      const imageUrl = document.getElementById("editImgUrl").value
      const shortHistory = document.getElementById("editArtworkShortHistory").value
      const origin = document.getElementById("editOrigin").value
      const price = new BigNumber(document.getElementById("editPrice").value)
                    .shiftedBy(ERC20_DECIMALS)
                    .toString()
    notification(`🎉Editing "${name}".`)
    try {
      const result = await contract.methods
        .editArtwork(index, name, imageUrl, shortHistory, origin, price)
        .send({ from: kit.defaultAccount })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    getArtWork()
    notification(`🎉Edited  "${name}"  successfully.`)
  })
  

  document.getElementById('editModal').addEventListener('show.bs.modal', (e) => {
  document.getElementById('editArtworkName').value = e.relatedTarget.dataset.name
  document.getElementById('editImgUrl').value = e.relatedTarget.dataset.image
  document.getElementById('editArtworkShortHistory').value = e.relatedTarget.dataset.shortHistory
  document.getElementById('editOrigin').value = e.relatedTarget.dataset.origin
  document.getElementById('editPrice').value = e.relatedTarget.dataset.price
  document.getElementById('editArtwork').setAttribute('data-index', e.relatedTarget.dataset.index)
});
 