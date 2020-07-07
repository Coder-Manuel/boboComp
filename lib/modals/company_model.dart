class CompanyModel{
  final String companyName;
  final String companyLocation;
  final String companyEmail;
  final String companyPhoneNumber;
  final String companyCertificate;
  final String status;

  CompanyModel({
    this.companyName,
    this.companyLocation,
    this.companyEmail,
    this.companyPhoneNumber,
    this.companyCertificate,
    this.status,
  });

  Map<String, dynamic> asMap(){
    return {
      "companyName": companyName,
      "companyLocation": companyLocation,
      "companyEmail": companyEmail,
      "companyPhoneNumber": companyPhoneNumber,
      "companyCertificate": companyCertificate,
      "status": status,
    };
  }

  CompanyModel fromMap(Map<String, dynamic> obj){
    return CompanyModel(
      companyName: obj['companyName'],
      companyLocation: obj['companyLocation'],
      companyEmail: obj['companyEmail'],
      companyPhoneNumber: obj['companyPhoneNumber'],
      status: obj['status'],
    );
  }
}