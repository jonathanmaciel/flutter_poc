import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:injectable/injectable.dart';

@Named('contactBook')
@LazySingleton(as: ContactBook)
class ContactBookImpl implements ContactBook {

  final Contacts contacts;
  
  final Means means;
  
  final Settings settings;
  
  final Map<String, Contact> _contactsMapped = new Map();

  ContactBookImpl(
      @Named("contacts") this.contacts, 
      @Named("means") this.means, 
      @Named("settings") this.settings
  );

  @override
  Future<dynamic> list() async {
    _contactsMapped.clear();
    final List<Contact> contactsListed = await contacts.list();
    for (final item in contactsListed) {
      _contactsMapped.putIfAbsent(item.id.toString(), () => item);
    }
  }

  @override
  List<Contact> get listed => [..._contactsMapped.values];

  @override
  int get count => _contactsMapped.length;

  @override
  bool get isEmpty => count == 0;

  @override
  Contact elementAt(int i) => _contactsMapped.values.elementAt(i);

  @override
  Future<Contact> add(Contact? contact) async {
    return (contact?.id == 0) ? await contacts.post(contact) : await contacts.put(contact);
  }

  @override
  Future<dynamic> remove(Contact contact) async {
    await contacts.delete(contact);
    await list();
  }

  @override
  Future<bool?> removeContactMean(ContactMeans? contactMean) async {
    final bool isRemoved = await means.remove(contactMean);
    final List<ContactMeans> values = await means.list(contactMean?.contact);
    contactMean?.contact?.means?.clear();
    contactMean?.contact?.means?.addAll(values);
    return isRemoved;
  }

  @override
  Future<dynamic> addContactMean(ContactMeans? contactMean) async {
    contactMean?.id == 0 ? await means.post(contactMean) : await means.put(contactMean);
    List<ContactMeans> values = await means.list(contactMean?.contact);
    contactMean?.contact?.means?.clear();
    contactMean?.contact?.means?.addAll(values);
  }

  @override
  Future<bool> getInstructionFisrtContactAddStatus() async {
    final Setting setting = await settings.item(Settings.INSTRUCTION_FISRT_CONTACT_ADD_STATUS);
    return setting.value == '1';
  }

  @override
  Future<dynamic> setInstructionFisrtContactAddStatus(bool value) async {
    final Setting setting = await settings.item(Settings.INSTRUCTION_FISRT_CONTACT_ADD_STATUS);
    setting.value = (value) ? '1' : '0';
    settings.put(setting);
  }

  @override
  Future<bool> getInstructionFisrtContactMeansAddStatus() async {
    final Setting setting = await settings.item(Settings.INSTRUCTION_FISRT_CONTACT_MEANS_ADD_STATUS);
    return setting.value == '1';
  }

  @override
  Future<dynamic> setInstructionFisrtContactMeansAddStatus(bool value) async {
    final Setting setting = await settings.item(Settings.INSTRUCTION_FISRT_CONTACT_MEANS_ADD_STATUS);
    setting.value = (value) ? '1' : '0';
    settings.put(setting);
  }
}

/* TODO ? */ abstract class ContactBook {

  Future<dynamic> list();

  List<Contact> get listed;

  int get count;

  bool get isEmpty;

  Contact elementAt(int i);

  Future<Contact> add(Contact? contact);

  Future<dynamic> remove(Contact contact);

  Future<bool?> removeContactMean(ContactMeans? contactMean);

  Future<dynamic> addContactMean(ContactMeans? contactMean);

  Future<bool> getInstructionFisrtContactAddStatus();

  Future<dynamic> setInstructionFisrtContactAddStatus(bool value);

  Future<bool> getInstructionFisrtContactMeansAddStatus();

  Future<dynamic> setInstructionFisrtContactMeansAddStatus(bool value);
}
