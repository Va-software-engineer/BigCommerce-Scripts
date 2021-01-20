import React, { useState, useEffect, useCallback} from 'react'
import { Panel, Text, Badge, Input, Table, Button, Modal } from '@bigcommerce/big-design';
import { StyledFooter } from './styled'

import Loader from '../../common/Loader';
import {ApiService} from '../../../../services/apiServices';
import {alertsManager} from "../../../../app";

export default function Summary(props) {
  let { storeId } = props;
  const [loading, setLoading] = useState(true);
  const [open, setOpen] = useState(false);
  const [storeScripts, setStoreScripts] = useState([]);
  const [storeInfo, setStoreInfo] = useState({});
  const [currentScript, setCurrentScript] = useState({});
  const [currentStatus, setCurrentStatus] = useState();
  const [storePropertyId, setStorePropertyId] = useState('');

  function AddAlert(title, details, type) {
    const alert = {
      header: title,
      messages: [
        {
          text: details,
        },
      ],
      type: type,
      onClose: () => null,
      autoDismiss: true
    }
    alertsManager.add(alert);
  }

  function orderStatus(status){
    switch(status) {
      case true:
        return (<Badge variant="success" label={'Enabled'}/>)
        break;
      default:
        return (<Badge variant="secondary" label={'Disabled'}/>)
    }
  }

  function updateStatus(id, status){
    return(
      <>
        { status &&
        <Button onClick={() => setValuesToUpdate(id, 'Disable')} actionType="destructive">Disable</Button>
        }
        { !status  &&
        <Button onClick={() => setValuesToUpdate(id, 'Enable')} variant='secondary'>Enable</Button>
        }
      </>
    )
  }

  function setValuesToUpdate(script_id, status) {
    if(storePropertyId == '' || storePropertyId == null){
      AddAlert('Error', 'Please add your Property ID first!', 'error')
      return null;
    }
    setCurrentStatus(status);
    setCurrentScript(storeScripts.find(element => element.id == script_id));
    setOpen(true);
  }

  function handleUpdate(){
    setOpen(false);
    setLoading(true);
    let statusState = currentStatus == 'Enable'? true : false;
    ApiService.updateScript({store_id: storeId, script_id: currentScript.id, status: statusState})
      .then(function (response){
        let newScripts = storeScripts;
        let newScript = storeScripts.find(element => element.id == currentScript.id)
        newScript.status = statusState;
        const findIndex = storeScripts.findIndex( script => script.id === currentScript.id);
        newScripts[findIndex] = newScript;
        setStoreScripts(newScripts);
        AddAlert('Script Updated', 'Script has been updated successfully!', 'success')
        setLoading(false);
      })
      . catch(function (error) {
        console.log(error);
        AddAlert('Error', 'Something went wrong, Please try again!', 'error')
        setLoading(false);
      })
  }

  const onChangeInput = useCallback(
    e => {
      const {value} = e.target;
      setStorePropertyId(value);
    })

  const onUpdateInput= () => {
      updateStoreProperty(storePropertyId);
    }

  function updateStoreProperty(value){
    if(!storeInfo.enabled_scripts){
      AddAlert('Property ID Updated', 'Property ID added successfully, Enabling your tags !', 'success')
    } else {
      AddAlert('Property ID Updated', 'Property ID Updated Successfully', 'success')
    }
    ApiService.updateStoreProperty({store_id: storeId, new_value: value})
      .then(function (response) {
        if(response.data.store.enabled_scripts && !storeInfo.enabled_scripts){
          AddAlert('Tag enabled', 'Tags enabled successfully!', 'success')
          RefatchScripts();
        }
      })
      .catch(function (error) {
        console.log(error);
        AddAlert('Error', 'Unable to fetch data, Please try again!', 'error')
      })
  }

  function RefatchScripts(){
    ApiService.getStoreScripts({store_id: storeId})
      .then(function (response) {
        setStoreScripts(response.data.scripts);
        setStoreInfo(response.data.store);
        setStorePropertyId(response.data.store.property_id);
        setLoading(false);
      })
  }

  useEffect(() => {
    ApiService.getStoreScripts({store_id: storeId})
      .then(function (response) {
        setStoreScripts(response.data.scripts);
        setStoreInfo(response.data.store);
        setStorePropertyId(response.data.store.property_id);
        setLoading(false);
      })
      .catch(function (error) {
        console.log(error);
        AddAlert('Error', 'Unable to fetch data. Please try again!', 'error')
      })
  },[]);

  return(
    <>
      { loading && <Loader />
      }
      { !loading &&
      <>
        <Panel header="Tag Settings">
          <h4>Property ID</h4>
          <p>This is the ID that your analytics provider uses to identity your business and site</p>
          <div style={{width: '40%'}}>
            <Input
              placeholder="Store Property Id"
              type="text"
              value={storePropertyId}
              onChange={onChangeInput}
            />
          </div>
        </Panel>
        <Panel header="Tags Managed By App">
          <Table
            columns={[
              { header: 'Name', hash: 'name', render: ({ name }) => name },
              { header: 'Pages', hash: 'pages', render: ({ pages }) => pages },
              { header: 'Location', hash: 'location', render: ({ location }) => location },
              { header: 'Status', hash: 'status', render: ({ status }) => orderStatus(status) },
              { header: 'Actions', hash: 'status', render: ({ id, status }) => updateStatus(id, status) },
            ]}
            items={!storeInfo.enabled_scripts ? [] : storeScripts}
            stickyHeader
          />
          { !storeInfo.enabled_scripts  &&
            <div style={{textAlign: 'center'}}>
              <h3>No tags added yet.</h3>
              <p>Enter your Property ID above and save it to add analytics tags to your storefront.</p>
            </div>
          }
        </Panel>

        <StyledFooter>
          <Button onClick={onUpdateInput} mobileWidth="auto">
            Save
          </Button>
        </StyledFooter>
      </>
      }

      <Modal
        actions={[
          { text: 'Cancel', variant: 'subtle', onClick: () => setOpen(false) },
          { text: 'Confirm', onClick: () => handleUpdate() },
        ]}
        header="Update Tags"
        isOpen={open}
        onClose={() => setOpen(false)}
        closeOnEscKey={true}
        closeOnClickOutside={true}
      >
        <Text>
          Are you sure, you want to {currentStatus} this script?
        </Text>
      </Modal>
    </>
  )}
