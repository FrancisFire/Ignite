import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ignite/dbcontrollers/firebasecontroller.dart';
import 'package:ignite/models/department.dart';

class DepartmentsFirebaseController extends FirebaseController<Department> {
  @override
  Future<void> delete(String id) async {
    await this.db.collection('departments').document(id).delete();
  }

  @override
  Future<void> deleteAll() async {
    this.db.collection('departments').getDocuments().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  @override
  Future<Department> get(String id) async {
    DocumentSnapshot ds =
        await this.db.collection('departments').document(id).get();
    Map<String, dynamic> data = ds.data;
    GeoPoint geo = ds.data['geopoint'];
    return new Department(
      id,
      data['cap'],
      data['city'],
      geo.latitude,
      geo.longitude,
      data['mail'],
      data['phone_number'],
      data['street'],
      data['number'],
    );
  }

  @override
  Future<List<Department>> getAll() async {
    QuerySnapshot qsDepartments =
        await this.db.collection('departments').getDocuments();
    List<Department> departments = new List<Department>();
    for (DocumentSnapshot ds in qsDepartments.documents) {
      Department d = await this.get(ds.documentID);
      departments.add(d);
    }
    return departments;
  }

  @override
  Future<Department> insert(Department object) async {
    DocumentReference ref = await this.db.collection('departments').add({
      'cap': object.getCap(),
      'city': object.getCity(),
      'geopoint': GeoPoint(object.getLat(), object.getLong()),
      'mail': object.getMail(),
      'phone_number': object.getPhoneNumber(),
      'street': object.getStreet(),
      'number': object.getNumber(),
    });
    return this.get(ref.documentID);
  }

  @override
  Future<Department> update(Department object) async {
    await this
        .db
        .collection('departments')
        .document(object.getId())
        .updateData({
      'cap': object.getCap(),
      'city': object.getCity(),
      'geopoint': GeoPoint(object.getLat(), object.getLong()),
      'mail': object.getMail(),
      'phone_number': object.getPhoneNumber(),
      'street': object.getStreet(),
      'number': object.getNumber(),
    });
    return this.get(object.getId());
  }
}
