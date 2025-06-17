class Customer{
  String? id;
  String name;
  int phoneNumber;

  Customer({
  this.id,
  required this.name,
  required this.phoneNumber,
});

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json){
    return Customer(id: json['id'], name: json['name'], phoneNumber: json['phone_number']);
  }
}