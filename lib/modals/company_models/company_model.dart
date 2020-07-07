class CompanyModel{
  final String id;
  final String companyName;
  final String companyLocation;
  final String companyEmail;
  final String companyPhoneNumber;
  final String companyCertificate;
  final String kraPin;
  final String paybill;
  final String status;
  final List<dynamic> users;

  CompanyModel({
    this.id='',
    this.companyName,
    this.companyLocation,
    this.companyEmail,
    this.companyPhoneNumber,
    this.companyCertificate,
    this.kraPin,
    this.paybill,
    this.status = 'pending',
    this.users=const[]
  });

  Map<String, dynamic> asMap(){
    return {
      "id": id,
      "companyName": companyName,
      "companyLocation": companyLocation,
      "companyEmail": companyEmail,
      "companyPhoneNumber": companyPhoneNumber,
      "companyCertificate": companyCertificate,
      "kraPin": kraPin,
      "paybill": paybill,
      "status": status,
      "users": users,
    };
  }

  CompanyModel fromMap(Map<String, dynamic> obj){
    return CompanyModel(
      id: obj['id'],
      companyName: obj['companyName'],
      companyLocation: obj['companyLocation'],
      companyEmail: obj['companyEmail'],
      companyPhoneNumber: obj['companyPhoneNumber'],
      companyCertificate: obj['companyCertificate'],
      kraPin: obj['kraPin'],
      paybill: obj['paybill'],
      status: obj['status'],
      users: obj['users'],
    );
  }
}