import { useState } from "react";
import {uploadToIPFS} from '../utils/NFTStorageUpload.js'
import JJAX from '../JJAX.json';
import { Input, InputNumber, Upload, Form, Button, Typography} from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { useLocation } from 'react-router';
const { TextArea } = Input;
const { Text } = Typography;



export default function UploadNFT () {
    const location = useLocation();
    const [formParams, updateFormParams] = useState({ name: '', author: '', price: '',type:'', description:''});
    const [fileURL1, setFileURL1] = useState(null);
    const [fileURL2, setFileURL2] = useState(null);
    const ethers = require("ethers");
    const [message, updateMessage] = useState('');
    

    //This function uploads the NFT mp3 to IPFS
    async function OnChangeSong(e) {
        var file = e.files;
        //check for file extension
        try {
            //upload the file to IPFS
            updateMessage("Uploading music.. please dont click anything!")
            const response = await uploadToIPFS(file);
            if(response.success === true) {
                updateMessage("")
                console.log("Uploaded Song: ", response.StorageURL)
                setFileURL1(response.StorageURL);
            }
        }
        catch(e) {
            console.log("Error during file upload", e);
        }
    }
    //This function uploads the NFT image to IPFS
    async function OnChangeImage(e) {
        var file = e.files;
        //check for file extension
        try {
            //upload the file to IPFS
            
            updateMessage("Uploading music.. please dont click anything!")
            const response = await uploadToIPFS(file);
            if(response.success === true) {
                updateMessage("")
                console.log("Uploaded image: ", response.StorageURL)
                setFileURL2(response.StorageURL);
            }
        }
        catch(e) {
            console.log("Error during file upload", e);
        }
    }

    //This function uploads the metadata to IPFS
    async function uploadMetadataToIPFS() {
        const {name, author, price, type, description} = formParams;
        //Make sure that none of the fields are empty
        if( !name || !description || !price || !author || !type || !fileURL1 || !fileURL2 )
        {
            updateMessage("Please fill all the fields!")
            return -1;
        }

        const nftJSON = {
            name, author, price, type, description,image: fileURL2, music:fileURL1
        }
        try {
            //upload the metadata JSON to IPFS
            const response = await uploadToIPFS(nftJSON);
            if(response.success === true){
                console.log("Uploaded JSON : ", response)
                return response.StorageURL;
            }
        }
        catch(e) {
            console.log("error uploading JSON metadata:", e)
        }
    }

    async function listNFT(e) {
        e.preventDefault();

        //Upload data to IPFS
        try {
            const metadataURL = await uploadMetadataToIPFS();
            if(metadataURL === -1)
                return;
            
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const recipientAddress = await signer.getAddress();

            updateMessage("Uploading NFT(takes 5 mins).. please dont click anything!")
        
            //Pull the deployed contract instance
            let contract = new ethers.Contract(JJAX.address, JJAX.abi, signer)

            //actually create the NFT
            let transaction = await contract.safeMint(recipientAddress , metadataURL)
            await transaction.wait()

            alert("Successfully listed your NFT!");
            
            updateMessage("");
            updateFormParams({ name: '', author: '', price: '',type:'',description:''});
            window.location.replace("/")
        }
        catch(e) {
            alert( "Upload error"+e )
        }
    }

        console.log("Working", process.env);
        return (
            <div>
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <div style={{ height: '20px' }}></div>
            <Form
            wrapperCol={{
            span: 20,
            }}
            layout="horizontal"
            
        >
            <Form.Item name="name">
            <Text strong>Name</Text>
            <Input 
            value={formParams.name}
            onChange={e => updateFormParams({...formParams, name: e.target.value})}
            />
            </Form.Item>
    
            <Form.Item  name="author">
            <Text strong>Author</Text>
            <Input 
            value={formParams.author}
            onChange={e => updateFormParams({...formParams, author: e.target.value})}
            />
            </Form.Item>
    
            <Form.Item  name="Type">
            <Text strong>Type</Text>
            <TextArea 
            value={formParams.type}
            onChange={e => updateFormParams({...formParams, type: e.target.value})}
            />
            </Form.Item>
    
            <Form.Item name="Price">
            <Text strong>Price</Text>
            <InputNumber
                value={formParams.price}
                onChange={value => updateFormParams({...formParams, price: value})}
            />
            <Text strong> Eth</Text>
            </Form.Item>

            <Form.Item  name="Description">
            <Text strong>Description</Text>
            <TextArea 
            value={formParams.description}
            onChange={e => updateFormParams({...formParams, description: e.target.value})}
            />
            </Form.Item>
            
            <Form.Item>
            <Text strong>Upload Music File</Text>
            <Form.Item name="music" >
                <Upload
                action="/upload-music.do"
                listType="text"
                accept=".mp3"
                onChange={OnChangeSong}
                >
                <div>
                    <PlusOutlined />
                    <div style={{ marginTop: 8 }}>Upload Music (MP3)</div>
                </div>
                </Upload>
            </Form.Item>
            </Form.Item>
    
            <Form.Item>
            <Text strong>Upload Image File</Text>
            <Form.Item name="image" >
                <Upload
                action="/upload-image.do"
                listType="picture-card"
                accept=".jpeg, .png"
                onChange={OnChangeImage}
                >
                <div>
                    <PlusOutlined />
                    <div style={{ marginTop: 8 }}>Upload Image (JPEG, PNG)</div>
                </div>
                </Upload>
            </Form.Item>
            </Form.Item>

    
            <Form.Item wrapperCol={{ offset: 4, span: 14 }}>
            <Button type="primary" htmlType="submit" onClick={listNFT}>
                Submit
            </Button>
            </Form.Item>
        </Form>
        </div>
            </div>
        
    )
}