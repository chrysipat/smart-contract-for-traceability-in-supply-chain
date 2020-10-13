pragma solidity ^0.4.0;

contract Traceability {

  address administrator;

  uint[]  locationcontract;

  uint    leadtimecontract;

  uint    autopaymentcontract;

  mapping (string => shipment) shipments;

  mapping (address => uint)    tokenbalances;

  mapping (address => uint)    totalshipments;

  mapping (address => uint)    successshipments;



  struct shipment {

    string  unit;

    uint    amount;

    uint[]  locationdata;

    uint    timestamp;

    address sender;

  }



  event successship (string _message, string trackingnumber, uint[] _locationdata, uint _timestamp,  address _sender);

  event autopayment (string _message, address _from, address _to, uint _quantity);

  event failureship (string _message);



  function Traceability (uint _initialtokensupply) {

    administrator = msg.sender;

    tokenbalances[administrator] = _initialtokensupply;

  }

  modifier onlyadministrator () {

    if (msg.sender != administrator) throw;

    _;

  }

  function sendtoken (address _from, address _to, uint _quantity)

  returns (bool success) {

    if (tokenbalances [_from] < _quantity){

      failureship ("The funds are deficient for the execution of the payment");

      return false;

    }

    tokenbalances [_from] -= _quantity;

    tokenbalances [_to]   += _quantity;

    autopayment ("The payment is executed", _from, _to, _quantity);

    return true;

  }

  function contractconditions(uint[] _location, uint _leadtime, uint _tokenpayment) onlyadministrator

  returns (bool success) {

    locationcontract = _location;

    leadtimecontract = _leadtime;

    autopaymentcontract = _autopayment;

    return true;

  }

  function shipmentdetails (string trackingnumber, string _unit, uint _amount, uint[] _locationdata)

  returns (bool success) {

    shipments[trackingnumber].unit = _unit;

    shipments[trackingnumber].amount = _amount;

    shipments[trackingnumber].locationdata = _locationdata;

    shipments[trackingnumber].timestamp = block.timestamp;

    shipments[trackingnumber].sender = msg.sender;

    totalshipments [msg.sender] += 1;

    successship ("Unit is shipped", trackingnumber, _locationdata, block.timestamp, msg.sender);

    return true;

  }

  function receiveshipment (string trackingnumber, string _unit, uint _amount, uint[] _locationdata)

  returns (bool success) {

    if (sha3(shipments[trackingnumber].unit) == sha3(_unit) && shipments[trackingnumber].amount == _amount) {

      successshipments [shipments[trackingnumber].sender] += 1;

      successship ("Unit is shipped", trackingnumber, _locationdata, block.timestamp, msg.sender);

      if (block.timestamp <= shipments [trackingnumber] .timestamp  + leadtimecontract

      && _locationdata [0] == locationcontract[0] && _locationdata [1] == locationcontract[1]){

        sendtoken (administrator, shipments[trackingnumber].sender, autopaymentcontract);

      }

      else {

        failureship ("Payment is not executed because of the unmet conditions");

      }

      return true;

    }

    else {

      failureship ("an error defined in unit or amount");

      return false;

    }

  }

  function removeshipment (string trackingnumber) onlyadministrator returns (bool successship){

    delete shipments [trackingnumber];

    return true;

  }

  function checkshipment (string trackingnumber) constant

  returns (string, uint, uint[], uint, address) {

    return (shipments [trackingnumber].unit,

    shipments[trackingnumber]. amount,

    shipments[trackingnumber].locationdata,

    shipments[trackingnumber].timestamp,

    shipments[trackingnumber].sender);

  }

  function checksuccessshipments(address _sender) constant

  returns (uint,uint) {

    return (successshipments[_sender], totalshipments[_sender]);

  }

  function reputationscore(address _sender) constant returns(uint){

    if (totalshipments[_sender] != 0 ) {

      return (100 * successshipments[_sender] / totalshipments[_sender]);

    }

    else{

      return 0;

    }

  }

}
