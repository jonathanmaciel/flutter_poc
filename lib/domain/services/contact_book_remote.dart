import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:injectable/injectable.dart';

@Named('contactBook')
@LazySingleton(as: ContactBook)
@Environment('http')
class ContactBookRemote implements ContactBook {

  final Contacts contacts;
  
  final Means means;
  
  final Settings settings;
  
  final Map<String, Contact> _contactsMapped = new Map();

  ContactBookRemote(
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
  Future<bool?> removeContactMean(ContactMeans? contactMeans) async {
    final bool isRemoved = await means.remove(contactMeans);
    final List<ContactMeans> values = await means.list(contactMeans?.contact);
    contactMeans?.contact?.means?.clear();
    contactMeans?.contact?.means?.addAll(values);
    return isRemoved;
  }

  @override
  Future<dynamic> addContactMean(ContactMeans? contactMeans) async {
    contactMeans?.id == 0 ? await means.post(contactMeans) : await means.put(contactMeans);
    final List<ContactMeans> values = await means.list(contactMeans?.contact);
    contactMeans?.contact?.means?.clear();
    contactMeans?.contact?.means?.addAll(values);
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
