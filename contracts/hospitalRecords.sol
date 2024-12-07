// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract HospitalRecords {
    // struct to store the patients info
    struct PatientRecord {
        uint256 patientId;
        string name;
        string[] treatment;
        uint256 timestamp; 
    }

    // struct to store medical personal
    struct MedicalPersonnel {
        address personnelAddress;
        string name;
        bool isAuthorized;
    }

    // state variables
    address owner;
    mapping(uint256 => PatientRecord) private  patientRecords;
    mapping(address => MedicalPersonnel) private  medicalPersonnel;
    address[] private  authorizedPersonnel;

    // Tracking the last assignned patient Id
    uint256 private  lastPatientId;

    
    // modifier to access control
    modifier  onlyOwner(){
        require(msg.sender == owner, "Contract owner access only.");
        _;
    }
    modifier onlyAuthorizedPersonnel(){
        require(medicalPersonnel[msg.sender].isAuthorized, "Not authorized medical personnel");
        _;
    }

    //set the contract owner
    constructor(){
        owner = msg.sender;
        lastPatientId = 0;
    }

    // Add authorized medical personal
    function addMedicalPersonnel(address _personnelAddress, string memory _name) public onlyOwner{
        require(!medicalPersonnel[_personnelAddress].isAuthorized, "Personnel already authorized");
        MedicalPersonnel memory newPersonnel = MedicalPersonnel ({
            personnelAddress:_personnelAddress,
            name:_name,
            isAuthorized:true
        });
        medicalPersonnel[_personnelAddress] = newPersonnel;
        authorizedPersonnel.push(_personnelAddress);
    }

    // remove a medical personnel
    function removeMedicalPersonnel(address _personnelAddress) public onlyOwner{
        require(medicalPersonnel[_personnelAddress].isAuthorized, "Personnel already authorized");
        medicalPersonnel[_personnelAddress].isAuthorized = false;

        // removed from authorized personnels
        for(uint i=0; i < authorizedPersonnel.length; i++){
            if(authorizedPersonnel[i] == _personnelAddress){
                authorizedPersonnel[i] = authorizedPersonnel[authorizedPersonnel.length - 1 ];
                authorizedPersonnel.pop();
                break;
            }
        }
    }

    // get all personnel
    function getAllAuthorizedPersonnel() public view returns (MedicalPersonnel[] memory){
        uint256 count = authorizedPersonnel.length; //get the length of the array
        MedicalPersonnel[] memory allAuthorizedPersonnel = new MedicalPersonnel[](count); 
        for (uint i =0; i< count; i++){
            address personnel = authorizedPersonnel[i];
            allAuthorizedPersonnel[i] = medicalPersonnel[personnel];
        }
        return  allAuthorizedPersonnel;
    }

    // get a single personnel
    function getSinglePersonnel(address _personnelAddress) public view returns (MedicalPersonnel memory){
        return medicalPersonnel[_personnelAddress];
    }

    // add a patient record

    function addPatientRecord(string memory _name, string[] memory _treatment) public onlyAuthorizedPersonnel {
        // Validate input data
        require(bytes(_name).length > 0, "Patient name is required");
        require(_treatment.length > 0, "At least one treatment is required");

        // Increment the lastPatientId to generate a unique patient ID
        lastPatientId++;

        // Create a new PatientRecord
        PatientRecord memory newRecord = PatientRecord({
            patientId: lastPatientId,
            name: _name,
            treatment: _treatment,
            timestamp: block.timestamp
        });

        // Store the new record in the mapping
        patientRecords[lastPatientId] = newRecord;

    }


    function getSinglePatientRecord(uint _patientId) public view  returns (PatientRecord memory){
        // ensure the id exist
        require(_patientId >0 && _patientId <= lastPatientId, "Patient record does not exists.");
        return patientRecords[_patientId];
    }

    function getAllPatientRecords() public view returns (PatientRecord[] memory){
        uint256 count = lastPatientId;
        PatientRecord[] memory allRecords = new PatientRecord[](count);
        for(uint i = 0; i < count; i++){
            allRecords[i] = patientRecords[i + 1];
        }
        return allRecords;
    }

    function addPatientTreatment(string memory _treatement, uint _patientId) public onlyAuthorizedPersonnel {
        require(_patientId >0 && _patientId <= lastPatientId, "Patient record does not exists.");
        patientRecords[_patientId].treatment.push(_treatement);
    }

}
