# Group-Project
JJAX Music Transfer

JJAX 2 Smart Contract:

Users can mint a NFT Smart token with the SafeMint function taking in two values, an address and the URI linking to a JSON file on the IPFS system.

This JSON file should be of the following format

This is an example i made earlier
{
"Attributes": [
{
"trait_type": "Artist",
"value": "Jake Grieves"
},
{
"trait_type": "Genre",
"value": "Drum Break"
}
],
"description": "Drum Break 112 BPM",
"image": "ipfs://QmQxKh6m3JHqv1Gm83KEMFjhYMJqEQ5Jn96cS9fGEjxwSH",
"mp3": "ipfs://QmXSKSWZJ87KG6owsQNqg43Xfyo3MgXayDhBJ7gqawq55i",
"name": "Funk No. 1 Tokyo Groove"
}

TODO:

We currently have everything in place to mint and send tokens however there are a couple features missing.

1) Uploading of JSON and File Data. This is more complex and may have to be done within the front end layer. I am currently using Pinata to upload to IPFS however we need a dedicated gateway in order to get full functionality, there are two options for this, either we can pay money and use a more expensive version of Pinata which gives us a gateway, or find a way around this. (Maybe NFT storage is a good idea for this) 
2) Write up on report 

Currently users have to upload files to the IPFS through Pinata, However after completion the users are able to send NFTs to one another and the functionality works as intended. 

So we need to find a way to upload the image MP3 and JSON file data to the IPFS system, to which it will then mint and create the NFT. This is a hard step but once we do this the project will be for the most part complete.
