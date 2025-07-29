import '../../../utils/constants/db_constants.dart';
import '../../../utils/data/state_iso_code_map.dart';
import '../../../utils/formatters/formatters.dart';
import '../../../utils/validators/validation.dart';

class AddressModel {
  String? firstName;
  String? lastName;
  String? phone ;
  String? email;
  String? companyName;
  String? gstNumber;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? pincode;
  String? country;
  DateTime? dateCreated;
  DateTime? dateModified;

  AddressModel({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.companyName,
    this.gstNumber,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.dateCreated,
    this.dateModified,
  });

  String get formattedPhoneNo => AppFormatter.formatPhoneNumber(phone ?? '0');
  String get name => '$firstName $lastName';

  // Method to check which fields are missing or empty
  List<String> validateFields() {
    List<String> missingFields = [];

    String? phoneError = Validator.validatePhoneNumber(phone);
    String? emailError = Validator.validateEmail(email);
    String? pincodeError = Validator.validatePinCode(pincode);

    if (firstName?.isEmpty ?? true) missingFields.add('First Name is missing');
    if (address1?.isEmpty ?? true) missingFields.add('Address is missing');
    if (city?.isEmpty ?? true) missingFields.add('City is missing');
    if (state?.isEmpty ?? true) missingFields.add('State is missing');
    if (country?.isEmpty ?? true) missingFields.add('Country is missing');
    if (phoneError != null) {
      missingFields.add(phoneError);
    }
    if (emailError != null) {
      missingFields.add(emailError);
    }
    if (pincodeError != null) {
      missingFields.add(pincodeError);
    }
    return missingFields;
  }

  factory AddressModel.fromJson(Map<String, dynamic> data) {
    return AddressModel(
      firstName: data[AddressFieldName.firstName],
      lastName: data[AddressFieldName.lastName],
      phone: data[AddressFieldName.phone],
      email: data[AddressFieldName.email],
      companyName: data[AddressFieldName.company],
      gstNumber: data[AddressFieldName.gstNumber],
      address1: data[AddressFieldName.address1],
      address2: data[AddressFieldName.address2],
      city: data[AddressFieldName.city],
      pincode: data[AddressFieldName.pincode],
      state: data[AddressFieldName.state],
      country: data[AddressFieldName.country],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) map[key] = value;
    }

    addIfNotNull(AddressFieldName.firstName, firstName);
    addIfNotNull(AddressFieldName.lastName, lastName);
    addIfNotNull(AddressFieldName.phone, phone);
    addIfNotNull(AddressFieldName.email, email);
    addIfNotNull(AddressFieldName.company, companyName);
    addIfNotNull(AddressFieldName.gstNumber, gstNumber);
    addIfNotNull(AddressFieldName.address1, address1);
    addIfNotNull(AddressFieldName.address2, address2);
    addIfNotNull(AddressFieldName.city, city);
    addIfNotNull(AddressFieldName.state, state);
    addIfNotNull(AddressFieldName.pincode, pincode);
    addIfNotNull(AddressFieldName.country, country);
    addIfNotNull(AddressFieldName.dateCreated, dateCreated);
    addIfNotNull(AddressFieldName.dateModified, dateModified);

    return map;
  }

  @override
  String toString() {
    return '$address1, $address2, $city, $state, $pincode, $country';
  }

  String completeAddress() {
    return '$name, $email, $phone, $address1, $address2, $city, $state, $pincode, $country';
  }
}