import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/department.dart';
import 'package:ignite/models/hydrant.dart';
import 'package:ignite/models/request.dart';
import 'package:ignite/models/user.dart';
import 'package:provider/provider.dart';

class DbProvider extends ChangeNotifier {
  final Firestore _db = Firestore.instance;

  Future<bool> isCurrentUserFireman(FirebaseUser curUser) async {
    QuerySnapshot querySnap = await _db
        .collection('users')
        .where('email', isEqualTo: "${curUser.email}")
        .getDocuments();
    return querySnap.documents[0]["isFireman"];
  }

  Future<List<Request>> getRequests() async {
    QuerySnapshot qsRequests = await _db.collection('requests').getDocuments();
    List<Request> requests = new List<Request>();

    for (DocumentSnapshot ds in qsRequests.documents) {
      DocumentReference approvedBy = ds.data['approved_by'];
      DocumentReference hydrant = ds.data['hydrant'];
      DocumentReference requestedBy = ds.data['requested_by'];
      requests.add(Request(ds.documentID, ds.data['approved'], ds.data['open'],
          approvedBy.documentID, hydrant.documentID, requestedBy.documentID));
    }
    return requests;
  }

  Future<List<Hydrant>> getApprovedHydrants() async {
    List<Hydrant> hydrants = new List<Hydrant>();
    List<Request> requests = await getRequests();
    for (Request r in requests) {
      if ((!r.getOpen()) && (r.getApproved())) {
        Hydrant newHydrant =
            await getHydrantByDocumentReference(r.getHydrant());
        hydrants.add(newHydrant);
      }
    }
    return hydrants;
  }

  Future<List<Department>> getDepartments() async {
    List<Department> deps = new List<Department>();
    QuerySnapshot qsDepartments =
        await _db.collection('departments').getDocuments();
    for (DocumentSnapshot ds in qsDepartments.documents) {
      GeoPoint geo = ds.data['geopoint'];
      print("SASSI: ${ds.documentID}");
      deps.add(Department(
        ds.documentID,
        ds.data['cap'],
        ds.data['city'],
        geo.latitude,
        geo.longitude,
        ds.data['mail'],
        ds.data['phone_number'],
        ds.data['street_number'],
      ));
    }
    return deps;
  }

  Future<Request> getRequestByDocumentReference(String ref) async {
    DocumentSnapshot ds = await _db.collection('requests').document(ref).get();
    Map<String, dynamic> data = ds.data;
    DocumentReference approvedBy = data['approved_by'];
    DocumentReference hydrant = data['hydrant'];
    DocumentReference requestedBy = data['requested_by'];
    return new Request(ref, data['approved'], data["open"],
        approvedBy.documentID, hydrant.documentID, requestedBy.documentID);
  }

  Future<Hydrant> getHydrantByDocumentReference(String ref) async {
    DocumentSnapshot ds = await _db.collection('hydrants').document(ref).get();
    Map<String, dynamic> data = ds.data;
    Timestamp time = data['last_check'];
    GeoPoint geo = data['geopoint'];
    return new Hydrant(
        ref,
        data['attack'][0],
        data['attack'][1],
        data['bar'],
        data['cap'],
        data['city'],
        geo.latitude,
        geo.longitude,
        data['color'],
        time.toDate(),
        data['notes'],
        data['opening'],
        data['place'],
        data['street_number'],
        data['type'],
        data['vehicle']);
  }

  Future<User> getUserByDocumentReference(String ref) async {
    DocumentSnapshot ds = await _db.collection('users').document(ref).get();
    Map<String, dynamic> data = ds.data;
    Timestamp time = data['birthday'];
    if (ds.data['isFireman'] == 'true') {
      DocumentReference department = data['department'];

      return new User(
          ref,
          data['email'],
          time.toDate(),
          data['name'],
          data['surname'],
          data['residence_street_number'],
          data['cap'],
          department.documentID);
    } else {
      return new User.onlyMail(data['email']);
    }
  }

  void approveRequest(Request request, FirebaseUser curUser) async {
    QuerySnapshot qsApprove = await _db
        .collection('users')
        .where('email', isEqualTo: curUser.email)
        .getDocuments();

    DocumentReference refApprove = qsApprove.documents[0].reference;
    await _db
        .collection('requests')
        .document(request.getDBReference())
        .updateData(
            {'approved': true, 'open': false, 'approved_by': refApprove});
  }

  void denyRequest(Request request, FirebaseUser curUser) async {
    QuerySnapshot qsApprove = await _db
        .collection('users')
        .where('email', isEqualTo: curUser.email)
        .getDocuments();
    DocumentReference refApprove = qsApprove.documents[0].reference;
    await _db
        .collection('requests')
        .document(request.getDBReference())
        .updateData(
            {'approved': false, 'open': false, 'approved_by': refApprove});
  }

  void addRequest(Hydrant hydrant, bool isFireman, FirebaseUser curUser) async {
    DocumentReference newHydrant = await _db.collection('hydrants').add({
      'attack': [hydrant.getFirstAttack(), hydrant.getSecondAttack()],
      'bar': hydrant.getPressure(),
      'cap': hydrant.getCap(),
      'city': hydrant.getCity(),
      'color': hydrant.getColor(),
      'geopoint': GeoPoint(hydrant.getLat(), hydrant.getLong()),
      'last_check': hydrant.getLastCheck(),
      'notes': hydrant.getNotes(),
      'opening': hydrant.getOpening(),
      'place': hydrant.getPlace(),
      'street_number': hydrant.getStreetNumber(),
      'type': hydrant.getType(),
      'vehicle': hydrant.getVehicle(),
    });

    QuerySnapshot qsReq = await _db
        .collection('users')
        .where('email', isEqualTo: curUser.email)
        .getDocuments();
    DocumentReference reqBy = qsReq.documents[0].reference;
    QuerySnapshot qsApp = await _db
        .collection('users')
        .where('email', isEqualTo: 'placeholder')
        .getDocuments();
    DocumentReference appBy = qsApp.documents[0].reference;
    DocumentReference newRequest = await _db.collection('requests').add({
      'approved': isFireman,
      'approved_by': appBy,
      'hydrant': newHydrant,
      'open': !isFireman,
      'requested_by': reqBy,
    });
  }
}
